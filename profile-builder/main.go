package main

import (
	"cloud.google.com/go/firestore"
	"cloud.google.com/go/logging"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"skillsmapper.org/profile-builder/internal/model"
	"skillsmapper.org/profile-builder/internal/util"
)

var cloudLogger *logging.Logger
var firestoreClient *firestore.Client

func init() {
	var err error

	projectID := util.MustGetenv("PROJECT_ID")
	serviceName := util.MustGetenv("SERVICE_NAME")

	ctx := context.Background()

	projectID = util.MustGetenv("projectID")

	err = os.Setenv("FIRESTORE_EMULATOR_HOST", "localhost:9000")
	if err != nil {
		// TODO: Handle error.
	}

	loggingClient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}

	cloudLogger = loggingClient.Logger(serviceName)

	firestoreClient, err = firestore.NewClient(ctx, "projectID")
	if err != nil {
		// TODO: Handle error.
	}
}

func main() {
	http.HandleFunc("/", processPubSub)
	http.ListenAndServe(":8080", nil)
}

func processPubSub(w http.ResponseWriter, r *http.Request) {
	var m util.PubSubMessage
	body, err := io.ReadAll(r.Body)
	if err != nil {
		cloudLogger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed ioutil.ReadAll: %s", err.Error()),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	if err := json.Unmarshal(body, &m); err != nil {
		cloudLogger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("json.Unmarshal: %v", err),
		})
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}
	var transaction model.FactsChanged
	if err := json.Unmarshal(m.Message.Data, &transaction); err != nil {
		cloudLogger.Log(logging.Entry{
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
