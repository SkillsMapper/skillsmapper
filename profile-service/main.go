package main

import (
	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/firestore"
	"cloud.google.com/go/logging"
	"context"
	"encoding/base64"
	"encoding/json"
	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/auth"
	"fmt"
	"github.com/gorilla/mux"
	"google.golang.org/api/option"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
	"io"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"sync/atomic"
	"time"
)

type Fact struct {
	ID        int       `json:"id"`
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	Level     string    `json:"level"`
	Skill     string    `json:"skill"`
}

type FactsChanged struct {
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	Facts     []Fact    `json:"facts"`
}

type Profile struct {
	User       string   `firestore:"user"`
	Name       string   `firestore:"name"`
	PhotoURL   string   `firestore:"photo_url"`
	Interested []string `firestore:"interested"`
	Learning   []string `firestore:"learning"`
	Using      []string `firestore:"using"`
	Used       []string `firestore:"used"`
}

var (
	logger          *logging.Logger
	authClient      *auth.Client
	firestoreClient *firestore.Client
)

func init() {
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
		log.Fatalf("failed to create logging client: %v", err)
	}
	logger = loggingClient.Logger(serviceName, logging.RedirectAsJSON(os.Stderr))

	conf := &firebase.Config{ProjectID: projectID}
	app, err := firebase.NewApp(ctx, conf)
	if err != nil {
		log.Fatalf("Failed to create Firebase app: %v", err)
	}

	authClient, err = app.Auth(ctx)
	if err != nil {
		log.Fatalf("Failed to create Firebase Auth client: %v", err)
	}

	// Set up Firestore client.
	firestoreClient, err = firestore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create Firestore client: %v", err)
	}
	defer func(firestoreClient *firestore.Client) {
		err := firestoreClient.Close()
		if err != nil {
			log.Fatalf("Failed to close Firestore client: %v", err)
		}
	}(firestoreClient)
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

	r.HandleFunc("/liveness", livenessHandler)
	r.HandleFunc("/readiness", readinessHandler(isReady))
	r.HandleFunc("/factschanged", func(w http.ResponseWriter, r *http.Request) {
		handleFactsChanged(w, r, firestoreClient)
	})
	r.HandleFunc("/api/profiles/me", corsMiddleware(func(w http.ResponseWriter, req *http.Request) {
		ctx := context.Background()
		handleGetMyProfile(ctx, firestoreClient, authClient, w, req)
	}))
	server.Handler = r

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "starting HTTP server"})

	isReady.Store(true)

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  "service is ready"})

	gracefulShutdown(server)

}
func handleFactsChanged(w http.ResponseWriter, r *http.Request, firestoreClient *firestore.Client) {
	type Message struct {
		Data string `json:"data"`
	}

	type PubSubMessage struct {
		Message Message `json:"message"`
	}

	var pubSubMessage PubSubMessage
	body, err := io.ReadAll(r.Body)
	log.Printf("body: %s", body)
	if err != nil {
		log.Printf("failed ioutil.ReadAll: %s", err.Error())
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	// Unmarshal the message
	if err := json.Unmarshal(body, &pubSubMessage); err != nil {
		log.Printf("json.Unmarshal: %v", err)
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	data, err := base64.StdEncoding.DecodeString(pubSubMessage.Message.Data)
	if err != nil {
		log.Printf("failed base64 decoding: %s", err.Error())
		http.Error(w, "Invalid data in PubSub message", http.StatusBadRequest)
		return
	}

	var factsChanged FactsChanged
	err = json.Unmarshal(data, &factsChanged)
	if err != nil {
		http.Error(w, "Invalid data in PubSub message", http.StatusBadRequest)
		return
	}

	profile := createOrUpdateProfile(context.Background(), firestoreClient, &factsChanged)
	log.Printf("Updated profile: %v", profile)

	w.WriteHeader(http.StatusOK)
}

func createOrUpdateProfile(ctx context.Context, firestoreClient *firestore.Client, event *FactsChanged) *Profile {
	profileRef := firestoreClient.Collection("profiles").Doc(event.User)

	// Check if the document exists
	doc, err := profileRef.Get(ctx)
	if err != nil && status.Code(err) == codes.NotFound {
		// Create a new profile with default values

		newProfile := &Profile{
			User:       event.User,
			Name:       "Profile",
			Interested: []string{},
			Learning:   []string{},
			Using:      []string{},
			Used:       []string{},
		}
		_, err := profileRef.Set(ctx, newProfile)
		if err != nil {
			log.Printf("Error creating new profile: %v", err)
			return nil
		}
		doc, _ = profileRef.Get(ctx)
	} else if err != nil {
		log.Printf("Error getting profile: %v", err)
		return nil
	}

	var profile Profile
	err = doc.DataTo(&profile)
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("error retrieving profile: %v", err)})
		return nil
	}

	profile.Interested = []string{}
	profile.Learning = []string{}
	profile.Using = []string{}
	profile.Used = []string{}

	// Update the profile with the new facts
	for _, fact := range event.Facts {
		switch fact.Level {
		case "interested":
			profile.Interested = appendIfNotExists(profile.Interested, fact.Skill)
		case "learning":
			profile.Learning = appendIfNotExists(profile.Learning, fact.Skill)
		case "using":
			profile.Using = appendIfNotExists(profile.Using, fact.Skill)
		case "used":
			profile.Used = appendIfNotExists(profile.Used, fact.Skill)
		default:
			log.Printf("Invalid level: %s", fact.Level)
		}
	}

	// Save the updated profile.
	_, err = profileRef.Set(ctx, profile)
	if err != nil {
		log.Printf("Error updating profile: %v", err)
		return nil
	}

	return &profile
}

func appendIfNotExists(slice []string, value string) []string {
	for _, v := range slice {
		if v == value {
			return slice
		}
	}
	return append(slice, value)
}

func handleGetMyProfile(ctx context.Context, firestoreClient *firestore.Client, authClient *auth.Client, w http.ResponseWriter, req *http.Request) {
	authHeader := req.Header.Get("X-Forwarded-Authorization")
	if authHeader == "" {
		authHeader = req.Header.Get("Authorization")
	}

	if authHeader == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}
	tokenString := strings.TrimPrefix(authHeader, "Bearer ")

	if tokenString == "" {
		http.Error(w, "Invalid Authorization header", http.StatusUnauthorized)
		return
	}

	token, err := authClient.VerifyIDToken(ctx, tokenString)
	if err != nil {
		http.Error(w, "Invalid JWT token", http.StatusUnauthorized)
		return
	}

	user := token.UID
	w.Header().Set("Content-Type", "application/json")
	profileRef := firestoreClient.Collection("profiles").Doc(user)
	doc, err := profileRef.Get(ctx)
	var profile Profile
	if err != nil && status.Code(err) == codes.NotFound {
		http.Error(w, "Profile dos not exist", http.StatusNotFound)
	} else if err != nil {
		http.Error(w, "Error retrieving profile", http.StatusInternalServerError)
		log.Printf("Error getting profile: %v", err)
		return
	} else {
		err := doc.DataTo(&profile)
		if err != nil {
			logger.Log(logging.Entry{
				Severity: logging.Error,
				Payload:  fmt.Sprintf("error retrieving profile: %v", err)})
			return
		}
	}

	// Retrieve the user's display name and photo URL from the token
	profile.User = user
	if name, ok := token.Claims["name"].(string); ok {
		profile.Name = name
	}
	if picture, ok := token.Claims["picture"].(string); ok {
		profile.PhotoURL = picture
	}
	err = json.NewEncoder(w).Encode(profile)
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to encode profile: %v", err)})
		return
	}
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

func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		// Set the CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Authorization, X-Forwarded-Authorization")

		// If it's a preflight request (OPTIONS method), return OK
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		// Otherwise, continue with the next handler
		next(w, r)
	}
}

func mustGetenv(k string) string {
	v := os.Getenv(k)
	if v == "" {
		log.Fatalf("statup failed: %s environment variable not set.", k)
	}
	return v
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
