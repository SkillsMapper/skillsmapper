#!/usr/bin/env bash
set -a; source ../.env; set +a
set -a; source .env; set +a

export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')

export GATEWAY_URL=$(gcloud api-gateway gateways describe skillsmapper-gateway --location=${REGION} --project=${PROJECT_ID} --format 'value(defaultHostname)')
