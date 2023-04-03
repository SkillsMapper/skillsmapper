package model

import "time"

type FactsChanged struct {
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	facts     []Fact    `json:"facts"`
}
