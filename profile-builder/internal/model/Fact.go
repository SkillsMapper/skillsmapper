package model

import "time"

type Fact struct {
	ID        int       `json:"id"`
	Timestamp time.Time `json:"timestamp"`
	User      string    `json:"user"`
	Level     string    `json:"level"`
	Skill     string    `json:"skill"`
}
