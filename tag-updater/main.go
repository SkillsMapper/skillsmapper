package tagupdater

import (
	"bytes"
	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/storage"
	"context"
	"fmt"
	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"google.golang.org/api/iterator"
	"log"
	"net/http"
	"os"
)

var (
	// clients are a global, initialized once per instance.
	bigQueryClient *bigquery.Client
	storageClient  *storage.Client
	projectID      = os.Getenv("PROJECT_ID")
	bucketName     = os.Getenv("BUCKET_NAME")
	objectName     = os.Getenv("OBJECT_NAME")
	// clients are initialized with context.Background() because they should
	// persist between function invocations.
	ctxBg = context.Background()
)

func init() {
	// err is pre-declared to avoid shadowing client.
	var err error
	bigQueryClient, err = bigquery.NewClient(ctxBg, projectID)
	if err != nil {
		log.Fatalf("bigquery.NewClient: %v", err)
	}
	storageClient, err = storage.NewClient(ctxBg)
	if err != nil {
		log.Fatalf("storage.NewClient: %v", err)
	}
	// register http function
	functions.HTTP("tag-updater", updateTags)
}

// updateTags is an HTTP Cloud Function.
func updateTags(w http.ResponseWriter, r *http.Request) {
	var err error
	numberOfTagsRetrieved, data, err := retrieveTags()
	if err != nil {
		log.Printf("failed to retrieve tags: %v\n", err)
		http.Error(w, "retrieving tags failed", http.StatusInternalServerError)
	}
	err = writeFile(data)
	if err != nil {
		log.Printf("failed to write file: %v\n", err)
		http.Error(w, "writing file failed", http.StatusInternalServerError)
	}
	message := fmt.Sprintf("%v tags retrieved and written to %s as %s", numberOfTagsRetrieved, bucketName, objectName)
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, message)
}

func writeFile(data []byte) (err error) {
	wc := storageClient.Bucket(bucketName).Object(objectName).NewWriter(ctxBg)
	_, err = wc.Write(data)
	if err != nil {
		log.Printf("failed to write: %v\n", err)
		return
	}
	err = wc.Close()
	if err != nil {
		log.Printf("failed to close: %v\n", err)
		return
	}
	return nil
}

func retrieveTags() (numberOfTagsRetrieved int, data []byte, err error) {
	var b bytes.Buffer
	q := bigQueryClient.Query("SELECT tag_name FROM bigquery-public-data.stackoverflow.tags order by tag_name")
	// execute the query
	it, err := q.Read(ctxBg)
	if err != nil {
		log.Printf("failed to execute query: %v", err)
		return
	}
	for {
		var row []bigquery.Value
		err = it.Next(&row)
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Printf("failed to iterate through results: %v", err)
			return
		}
		b.WriteString(fmt.Sprintf("%v\n", row[0]))
		numberOfTagsRetrieved++
	}
	data = b.Bytes()
	return numberOfTagsRetrieved, data, nil
}
