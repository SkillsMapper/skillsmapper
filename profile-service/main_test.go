package main

/*
import (
	"bytes"
	"cloud.google.com/go/firestore"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestCreateOrUpdateProfile(t *testing.T) {
	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID")

	// Set up Firestore client.
	firestoreClient, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		t.Fatalf("Failed to create Firestore client: %v", err)
	}
	defer firestoreClient.Close()

	event := &FactsChanged{
		User: "testuser",
		Facts: []Fact{
			{Skill: "Go", Level: "using"},
			{Skill: "Python", Level: "used"},
		},
	}

	profile := createOrUpdateProfile(ctx, firestoreClient, event)
	if profile == nil {
		t.Fatal("Expected a profile, got nil")
	}

	if profile.User != "testuser" {
		t.Errorf("Expected profile user to be 'testuser', got '%s'", profile.User)
	}

	if len(profile.Using) != 1 || profile.Using[0] != "Go" {
		t.Errorf("Expected profile using to have one element 'Go', got %v", profile.Using)
	}

	if len(profile.Used) != 1 || profile.Used[0] != "Python" {
		t.Errorf("Expected profile used to have one element 'Python', got %v", profile.Used)
	}
}

func TestHandleFactsChanged(t *testing.T) {
	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID")

	// Set up Firestore client.
	firestoreClient, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		t.Fatalf("Failed to create Firestore client: %v", err)
	}
	defer firestoreClient.Close()

	// Clean up test data.
	defer func(doc *firestore.DocumentRef, ctx context.Context, preconds ...firestore.Precondition) {
		_, err := doc.Delete(ctx, preconds...)
		if err != nil {
			t.Fatalf("Failed to delete test profile: %v", err)
		}
	}(firestoreClient.Collection("profiles").Doc("testuser"), ctx)

	body := `{
		"user": "testuser",
		"facts": [
			{"skill": "Go", "level": "using"},
			{"skill": "Python", "level": "used"}
		]
	}`

	req := httptest.NewRequest("POST", "/factschanged", bytes.NewBufferString(body))
	w := httptest.NewRecorder()

	handleFactsChanged(w, req, firestoreClient)

	if w.Code != http.StatusNoContent {
		t.Errorf("Expected status code %d, got %d", http.StatusNoContent, w.Code)
	}
}

func TestGetProfileHandler(t *testing.T) {
	ctx := context.Background()
	projectID := os.Getenv("PROJECT_ID")

	// Set up Firestore client.
	firestoreClient, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		t.Fatalf("Failed to create Firestore client: %v", err)
	}
	defer firestoreClient.Close()

	// Prepare a test profile.
	profile := &Profile{
		User:       "testuser",
		Name:       "Profile",
		Interested: []string{"Java"},
		Learning:   []string{"C++"},
		Using:      []string{"Go"},
		Used:       []string{"Python"},
	}
	_, err = firestoreClient.Collection("profiles").Doc("testuser").Set(ctx, profile)
	if err != nil {
		t.Fatalf("Failed to set up test profile: %v", err)
	}

	// Clean up test data.
	defer firestoreClient.Collection("profiles").Doc("testuser").Delete(ctx)

	req := httptest.NewRequest("GET", "/profile?user=testuser", nil)
	w := httptest.NewRecorder()

	getProfileHandler(w, req, firestoreClient)

	if w.Code != http.StatusOK {
		t.Errorf("Expected status code %d, got %d", http.StatusOK, w.Code)
	}

	var retrievedProfile Profile
	err = json.NewDecoder(w.Body).Decode(&retrievedProfile)
	if err != nil {
		t.Fatalf("Failed to decode response: %v", err)
	}

	if retrievedProfile.User != profile.User {
		t.Errorf("Expected profile user to be '%s', got '%s'", profile.User, retrievedProfile.User)
	}
	if retrievedProfile.Name != profile.Name {
		t.Errorf("Expected profile name to be '%s', got '%s'", profile.Name, retrievedProfile.Name)
	}
	if !equalStringSlices(retrievedProfile.Interested, profile.Interested) {
		t.Errorf("Expected profile interested to be %v, got %v", profile.Interested, retrievedProfile.Interested)
	}
	if !equalStringSlices(retrievedProfile.Learning, profile.Learning) {
		t.Errorf("Expected profile learning to be %v, got %v", profile.Learning, retrievedProfile.Learning)
	}
	if !equalStringSlices(retrievedProfile.Using, profile.Using) {
		t.Errorf("Expected profile using to be %v, got %v", profile.Using, retrievedProfile.Using)
	}
	if !equalStringSlices(retrievedProfile.Used, profile.Used) {
		t.Errorf("Expected profile used to be %v, got %v", profile.Used, retrievedProfile.Used)
	}
}

func equalStringSlices(a, b []string) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}
*/
