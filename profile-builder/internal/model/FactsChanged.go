package model

import "time"

type FactsChanged struct {
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	Facts     []Fact    `json:"facts"`
}
