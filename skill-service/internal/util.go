package internal

import (
	"log"
	"os"
)

func MustGetenv(k string) string {
	v := os.Getenv(k)
	if v == "" {
		log.Fatalf("Warning: %s environment variable not set.", k)
	}
	return v
}
