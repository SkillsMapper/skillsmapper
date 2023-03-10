package model

type FactsChanged struct {
	TxnID string `json:"txnid" db:"txnid"`
}
