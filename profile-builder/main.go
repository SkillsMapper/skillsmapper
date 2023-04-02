package main

import (
	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/firestore"
	"cloud.google.com/go/logging"
	"context"
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
	"skillsmapper.org/profile-builder/internal/model"
	"skillsmapper.org/profile-builder/internal/util"
	"sync/atomic"
	"time"
)

var (
	logger          *logging.Logger
	firestoreClient *firestore.Client
)

func init() {
	var err error
	serviceName := util.MustGetenv("SERVICE_NAME")

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
		option.WithGRPCDialOption(
			grpc.WithTransportCredentials(insecure.NewCredentials()),
		))
	if err != nil {
		log.Fatalf("failed to create client: %v", err)
	}
	logger = loggingClient.Logger(serviceName, logging.RedirectAsJSON(os.Stderr))

	firestoreClient, err = firestore.NewClient(ctx, "projectID")
	if err != nil {
		// TODO: Handle error.
	}
}

func main() {
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
	r.HandleFunc("/liveness", liveness)
	r.HandleFunc("/readiness", readiness(isReady))
	r.HandleFunc("/", processPubSub)
	server.Handler = r

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "starting HTTP server"})

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server closed: %v", err)
		}
	}()
	isReady.Store(true)

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "service is ready"})

	ctx := context.Background()
	// Listen for SIGINT to gracefully shutdown.
	nctx, stop := signal.NotifyContext(ctx, os.Interrupt, os.Kill)
	defer stop()
	<-nctx.Done()
	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "shutdown initiated"})

	// Cloud Run gives apps 10 seconds to shutdown. See
	// https://cloud.google.com/blog/topics/developers-practitioners/graceful-shutdowns-cloud-run-deep-dive
	// for more details.
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	server.Shutdown(ctx)
	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "shutdown complete"})
}

func readiness(isReady *atomic.Value) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		if isReady == nil || !isReady.Load().(bool) {
			http.Error(w, http.StatusText(http.StatusServiceUnavailable), http.StatusServiceUnavailable)
			return
		}
		w.WriteHeader(http.StatusOK)
	}
}

func liveness(w http.ResponseWriter, _ *http.Request) {
	w.WriteHeader(http.StatusOK)
}

func processPubSub(w http.ResponseWriter, r *http.Request) {
	var m util.PubSubMessage
	body, err := io.ReadAll(r.Body)
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed ioutil.ReadAll: %s", err.Error()),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	if err := json.Unmarshal(body, &m); err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("json.Unmarshal: %v", err),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	var transaction model.FactsChanged
	if err := json.Unmarshal(m.Message.Data, &transaction); err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("json.Unmarshal: %v", err),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	generateProfile()
}

func generateProfile() {
	firestoreClient.Collection("profiles").Doc("profileID").Set(context.Background(), map[string]interface{}{})
}
