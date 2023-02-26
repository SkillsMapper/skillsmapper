package util

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
)

type Entry struct {
	Message   string `json:"message"`
	Severity  string `json:"severity,omitempty"`
	Trace     string `json:"logging.googleapis.com/trace,omitempty"`
	Component string `json:"component,omitempty"`
}

func (e Entry) String() string {
	if e.Severity == "" {
		e.Severity = "INFO"
	}
	out, err := json.Marshal(e)
	if err != nil {
		log.Printf("json.Marshal: %v", err)
	}
	return string(out)
}

func GetTrace(r *http.Request, projectID string) (trace string) {
	if projectID != "" {
		traceHeader := r.Header.Get("X-Cloud-Trace-Context")
		traceParts := strings.Split(traceHeader, "/")
		if len(traceParts) > 0 && len(traceParts[0]) > 0 {
			trace = fmt.Sprintf("projects/%s/traces/%s", projectID, traceParts[0])
		}
	}
	return trace
}
