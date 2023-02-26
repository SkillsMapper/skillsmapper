package tagupdater

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestUpdateTags(t *testing.T) {
	req := httptest.NewRequest("GET", "/", nil)
	req.Header.Add("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	updateTags(rr, req)

	want := http.StatusOK
	if got := rr.Code; got != want {
		t.Errorf("updateTags() = %q, want %q", got, want)
	}
}
