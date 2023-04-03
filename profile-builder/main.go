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
		log.Fatalf("failed to create loggin client: %v", err)
	}
	logger = loggingClient.Logger(serviceName, logging.RedirectAsJSON(os.Stderr))

	firestoreClient, err = firestore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("failed to create firestore client: %v", err)
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
	logger.Log(logging.Entry{
		Severity: logging.Error,
		Payload:  fmt.Sprintf("body: %s", body),
	})
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed ioutil.ReadAll: %s", err.Error()),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	//Unmarshal the message
	if err := json.Unmarshal(body, &m); err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("json.Unmarshal: %v", err),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	//Unmarshal the message data (factChanged)
	var factsChanged model.FactsChanged
	if err := json.Unmarshal(m.Message.Data, &factsChanged); err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("json.Unmarshal: %v", err),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  fmt.Sprintf("factsChanged: %v", factsChanged),
	})
	generateProfile(factsChanged.User, factsChanged.Facts)
}

func generateProfile(user string, facts []model.Fact) {
	ctx := context.Background()
	wr, err := firestoreClient.Doc(fmt.Sprintf("profiles/%s", user)).Create(ctx, map[string]interface{}{
		"capital": "Denver",
		"pop":     5.5,
	})
	if err != nil {
		log.Fatalf("firestore Doc Create error:%s\n", err)
	}
	fmt.Println(wr.UpdateTime)

	//update
	if true {
		if _, err := firestoreClient.Doc(fmt.Sprintf("profiles/%s", user)).
			Update(context.Background(), []firestore.Update{{"FlagColor", nil, "Red"}, {Path: "Location", Value: "Middle"}}); err != nil {
			log.Fatalf("Update error: %s\n", err)
		}
	} /*
		if err != nil {
			logger.Log(logging.Entry{
				Severity: logging.Error,
				Payload:  fmt.Sprintf("firestoreClient.Collection(\"profiles\").Doc(user).Get(ctx): %v", err),
			})
		}
		if doc.Exists() {
			logger.Log(logging.Entry{
				Severity: logging.Info,
				Payload:  fmt.Sprintf("profile for user %s already exists", user),
			})
			return
		}
		logger.Log(logging.Entry{
			Severity: logging.Info,
			Payload:  fmt.Sprintf("generating profile for user %s, with %v", user, facts),
		})*/
}
