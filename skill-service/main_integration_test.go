package main

import (
	"net/http"
	"net/http/httptest"
	"skillsmapper.org/skill-service/internal/autocomplete"
	"testing"
)

func TestAutocompleteHandler(t *testing.T) {
	trie := autocomplete.New()
	trie.Insert("test")
	handler := autocompleteHandler(trie)

	req, err := http.NewRequest("GET", "/autocomplete?prefix=test", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handlerFunc := http.HandlerFunc(handler)

	handlerFunc.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := `{"results":["test"]}`
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}
