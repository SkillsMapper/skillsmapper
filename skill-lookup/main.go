package main

import (
	"bufio"
	"cloud.google.com/go/logging"
	"cloud.google.com/go/storage"
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"skillsmapper.org/skill-lookup/internal/skill/autocomplete"
	"skillsmapper.org/skill-lookup/internal/util"
	"time"
)

type autocompleteResponse struct {
	Results []string `json:"results"`
}

var (
	//go:embed template/template.html
	indexTemplate string
	bucketName    string
	objectName    string
	logger        *logging.Logger
	storageClient *storage.Client
)

func init() {
	bucketName = util.MustGetenv("BUCKET_NAME")
	objectName = util.MustGetenv("OBJECT_NAME")
	projectID := util.MustGetenv("PROJECT_ID")
	serviceName := util.MustGetenv("SERVICE_NAME")

	ctx := context.Background()
	loggingClient, err := logging.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("failed to create client: %v", err)
	}
	logger = loggingClient.Logger(serviceName)

	storageClient, err = storage.NewClient(ctx)
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to create storage client: %v", err)})
	}

}

func main() {
	trie := autocomplete.New()
	populate(*trie, bucketName, objectName)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Parse the template file
		tmpl, err := template.New("index").Parse(indexTemplate)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Execute the template and write the result to the response
		err = tmpl.Execute(w, nil)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	})
	http.HandleFunc("/autocomplete", func(w http.ResponseWriter, r *http.Request) {
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
		json, err := json.Marshal(response)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		duration := time.Since(start)
		logger.Log(logging.Entry{
			Severity: logging.Debug,
			Payload:  fmt.Sprintf(fmt.Sprintf("autocomplete for %s took %v", prefix, duration))})
		w.Header().Set("Content-Type", "application/json")
		w.Write(json)
	})

	http.ListenAndServe(":8080", nil)
}

func populate(trie autocomplete.Trie, bucketName string, objectName string) {
	start := time.Now()

	// err is pre-declared to avoid shadowing client.
	var err error

	// Get a handle to the bucket
	bucket := storageClient.Bucket(bucketName)
	// Get a handle to the object
	object := bucket.Object(objectName)

	// Read the contents of the object
	reader, err := object.NewReader(context.Background())
	if err != nil {
		logger.Log(logging.Entry{
			Severity: logging.Error,
			Payload:  fmt.Sprintf("failed to read tags object %s: %v", objectName, err)})
	}
	defer reader.Close()

	scanner := bufio.NewScanner(reader)
	scanner.Text() // skip first line
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

	duration := time.Since(start)
	logger.Log(logging.Entry{
		Severity: logging.Debug,
		Payload:  fmt.Sprintf("populate took %v", duration)})

	logger.Log(logging.Entry{
		Severity: logging.Info,
		Payload:  fmt.Sprintf("%v tags loaded\n", count)})
}
