package old

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"skillsmapper.org/profile-builder/old"
	"testing"
)

func TestMessageHandler(t *testing.T) {
	// Create a request with a JSON payload
	msg := `{"deliveryAttempt":7,"message":{"attributes":{"replyChannel":"nullChannel"},"data":"eyJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImZhY3RzIjpbeyJpZCI6MSwidGltZXN0YW1wIjoiMjAyMy0wNC0wM1QxMDoyMzozOS4xMTM5NDIrMDE6MDAiLCJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImxldmVsIjoibGVhcm5pbmciLCJza2lsbCI6ImphdmEifSx7ImlkIjoyLCJ0aW1lc3RhbXAiOiIyMDIzLTA0LTAzVDEwOjI1OjQ0LjcxODgzNiswMTowMCIsInVzZXIiOiJ2OXFlcGg3TUxCZjVFZ0ZZbFVDS01UWXdRNmkxIiwibGV2ZWwiOiJsZWFybmluZyIsInNraWxsIjoiamF2YSJ9LHsiaWQiOjMsInRpbWVzdGFtcCI6IjIwMjMtMDQtMDNUMTA6MzE6MjAuMDgyOTE1KzAxOjAwIiwidXNlciI6InY5cWVwaDdNTEJmNUVnRllsVUNLTVRZd1E2aTEiLCJsZXZlbCI6ImxlYXJuaW5nIiwic2tpbGwiOiJqYXZhIn0seyJpZCI6NCwidGltZXN0YW1wIjoiMjAyMy0wNC0wM1QxMTozOTozNC4xMzcwNDkrMDE6MDAiLCJ1c2VyIjoidjlxZXBoN01MQmY1RWdGWWxVQ0tNVFl3UTZpMSIsImxldmVsIjoibGVhcm5pbmciLCJza2lsbCI6ImphdmEifSx7ImlkIjo1LCJ0aW1lc3RhbXAiOiIyMDIzLTA0LTAzVDEyOjQ0OjI4LjA1MTk2MSswMTowMCIsInVzZXIiOiJ2OXFlcGg3TUxCZjVFZ0ZZbFVDS01UWXdRNmkxIiwibGV2ZWwiOiJsZWFybmluZyIsInNraWxsIjoiamF2YSJ9XSwidGltZXN0YW1wIjoiMjAyMy0wNC0wM1QxMjo0NDoyOC4xNDkyNDgrMDE6MDAifQ==","messageId":"7391262173992046","message_id":"7391262173992046","publishTime":"2023-04-03T11:44:28.878Z","publish_time":"2023-04-03T11:44:28.878Z"},"subscription":"projects/skillsmapper-org/subscriptions/fact_changed_subscription"}`
	req, err := http.NewRequest("POST", "/", bytes.NewBuffer([]byte(msg)))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")

	// Create a ResponseRecorder to record the response
	rr := httptest.NewRecorder()

	// Create a test HTTP server with the messageHandler
	handler := http.HandlerFunc(main.processPubSub)

	// Serve the request and record the response
	handler.ServeHTTP(rr, req)

	// Check the status code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}
}
