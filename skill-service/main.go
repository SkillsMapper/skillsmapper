package main

import (
	"bufio"
	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/logging"
	"cloud.google.com/go/storage"
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"github.com/gorilla/mux"
	"google.golang.org/api/option"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"io"
	"log"
	"net/http"
	"os"
	"os/signal"
	"skillsmapper.org/skill-service/internal/autocomplete"
	"sync/atomic"
	"time"
)

type autocompleteResponse struct {
	Results []string `json:"results"`
}

var (
	bucketName    string
	objectName    string
	logger        *logging.Logger
	storageClient *storage.Client
)

func init() {
	bucketName = mustGetenv("BUCKET_NAME")
	objectName = mustGetenv("OBJECT_NAME")
	serviceName := mustGetenv("SERVICE_NAME")

	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID")
	if projectID == "" {
		projID, err := metadata.ProjectID()
		if err != nil {
			log.Fatalf("unable to detect Project ID from PROJECT_ID or metadata server: %v", err)
		}
		projectID = projID
	}

	loggingClient, err := logging.NewClient(ctx, projectID,
		option.WithoutAuthentication(),
		option.WithGRPCDialOption(grpc.WithTransportCredentials(insecure.NewCredentials())))
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to create logging client: %v", err)})
		log.Fatalf("failed to create logging client: %v", err)
	}
	logger = loggingClient.Logger(serviceName, logging.RedirectAsJSON(os.Stderr))

	storageClient, err = storage.NewClient(ctx)
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to create storage client: %v", err)})
		log.Fatalf("failed to create storage client: %v", err)
	}
}

func main() {
	trie := autocomplete.New()

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	server := &http.Server{
		Addr: ":" + port,
		// Add some defaults, should be changed to suit your use case.
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	r := mux.NewRouter()
	isReady := &atomic.Value{}
	isReady.Store(false)

	r.HandleFunc("/liveness", livenessHandler)
	r.HandleFunc("/readiness", readinessHandler(isReady))
	r.HandleFunc("/autocomplete", autocompleteHandler(trie))
	server.Handler = r

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "starting HTTP server on port " + port})

	populate(*trie, bucketName, objectName)

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server closed: %v", err)
		}
	}()
	isReady.Store(true)

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "service is ready on port " + port})

	gracefulShutdown(server)
}

/*
Listen for SIGINT to shut down gracefully.
Cloud Run gives apps 10 seconds for shutdown.
*/
func gracefulShutdown(server *http.Server) {
	ctx := context.Background()
	nctx, stop := signal.NotifyContext(ctx, os.Interrupt, os.Kill)
	defer stop()
	<-nctx.Done()
	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "shutdown initiated"})

	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		log.Printf("HTTP server shutdown error: %v", err)
	}
	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "shutdown complete"})
}

func autocompleteHandler(trie *autocomplete.Trie) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		// Get the prefix from the query string
		prefix := r.URL.Query().Get("prefix")
		if prefix == "" {
			http.Error(w, "prefix is required", http.StatusBadRequest)
			return
		}

		results := trie.Search(prefix, 10)

		// Return the results as a JSON response
		response := autocompleteResponse{Results: results}
		responseJSON, err := json.Marshal(response)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		duration := time.Since(start)
		logger.Log(logging.Entry{
			Severity: logging.Debug,
			Payload:  fmt.Sprintf("autocomplete for %s took %v", prefix, duration)})
		w.Header().Set("Content-Type", "application/json")
		if _, err := w.Write(responseJSON); err != nil {
			logger.Log(logging.Entry{
				Severity: logging.Error,
				Payload:  fmt.Sprintf("error writing JSON response: %v", err)})
		}
	}
}

func closeReader(reader io.Closer) {
	err := reader.Close()
	if err != nil {
		log.Printf("error closing reader: %v", err)
	}
}

func populate(trie autocomplete.Trie, bucketName string, objectName string) {
	start := time.Now()

	// err is pre-declared to avoid shadowing the client.
	var err error

	// Get a handle to the bucket
	bucket := storageClient.Bucket(bucketName)

	// Get a handle to the object
	object := bucket.Object(objectName)

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  fmt.Sprintf("loading tags from %s/%s", bucketName, objectName)})

	// Read the contents of the object
	reader, err := object.NewReader(context.Background())
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to read tags object %s: %v", objectName, err)})
	}
	defer closeReader(reader)

	scanner := bufio.NewScanner(reader)
	scanner.Text() // skip the first line
	count := 0
	for scanner.Scan() {
		tag := scanner.Text()
		trie.Insert(tag)
		count++
	}
	// Check for any errors that may have occurred during scanning
	err = scanner.Err()
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed read data: %v", err)})
		return
	}

	duration := time.Since(start).Seconds()
	logger.Log(logging.Entry{
		Severity: logging.Debug,
		Payload:  fmt.Sprintf("populate tags took %.2fs", duration)})

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  fmt.Sprintf("loaded %d tags", count)})
}

func readinessHandler(isReady *atomic.Value) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		if isReady == nil || !isReady.Load().(bool) {
			http.Error(w, http.StatusText(http.StatusServiceUnavailable), http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}

func livenessHandler(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func mustGetenv(k string) string {
	v := os.Getenv(k)
	if v == "" {
		log.Fatalf("statup failed: %s environment variable not set.", k)
	}
	return v
}
