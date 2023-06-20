package internal

import (
	"log"
	"os"
)

// MustGetenv retrieves the value of the environment variable named by the key.
// If the variable is present in the environment and non-empty, it returns the value.
// If the variable is not present, or is set to the empty string, it logs a fatal error message and exits the program.
func MustGetenv(k string) string {
	v := os.Getenv(k)
	if v == "" {
		log.Fatalf("Warning: %s environment variable not set.", k)
	}
	return v
}
