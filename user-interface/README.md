# Skills Mapper User Interface

## Run Locally

Apply local .env:

```shell
set -a; source ../.env; set +a 
set -a; source .env; set +a
```

## Exposing the Backend

Updating docs:

```shell
swagger-codegen generate -i api.yaml -l html2 -o ./src/api-docs
```

## Hosting with Cloud Run

```shell
gcloud builds submit --tag gcr.io/${PROJECT_ID}/user-interface
```

```shell
gcloud run deploy --image gcr.io/${PROJECT_ID}/user-interface
```

Get the endpoint:
```shell
gcloud run services describe user-interface --platform managed --region europe-west2 --format 'value(status.url)'
```

## Create an API Gateway

Enable API Gateway and Service Control

```shell
gcloud services enable apigateway.googleapis.com
gcloud services enable servicecontrol.googleapis.com
```

```shell
export API_NAME=skillsmapper
export API_SPEC_FILE=api.yaml
```

Create both an API and an API Config:

```shell
gcloud api-gateway api-configs create ${API_NAME}-config \
  --api=${API_NAME} \
  --openapi-spec=${API_SPEC_FILE} \
  --project=${PROJECT_ID}
```

Delete the API Config with an updated spec:

```shell
gcloud api-gateway api-configs delete ${API_NAME}-config \
  --api=${API_NAME} \
  --project=${PROJECT_ID}
```

## Create a Gateway

Create an API Gateway:

```shell
gcloud api-gateway gateways create ${API_NAME}-gateway \
  --api=${API_NAME} \
  --api-config=${API_NAME}-config \
  --location=${REGION} \
  --project=${PROJECT_ID}
```

Delete the gateway:
```shell
gcloud api-gateway gateways delete ${API_NAME}-gateway \
  --location=${REGION} \
  --project=${PROJECT_ID}
```

Get the URL:
```shell
export GATEWAY_URL=$(gcloud api-gateway gateways describe skillsmapper-gateway --location=${REGION} --project=${PROJECT_ID} --format 'value(defaultHostname)')
```

### Add endpoint to Authentication

Add to Settings>Authorized Domains:

skillsmapper-gateway-7dehhhx6.uc.gateway.dev

Test the endpoint:

### UI

```shell
curl -X GET "https://${GATEWAY_URL}"
```

### Skills

Direct:
```shell
curl -X GET "${SKILL_LOOKUP_URL}/autocomplete?prefix=java"
````

Via gateway
```shell
curl -X GET "https://${GATEWAY_URL}/skills/autocomplete?prefix=java"
```

### Facts

```shell
export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')
```

```shell
curl -X GET "https://${GATEWAY_URL}/facts" \
  -H "Authorization: Bearer ${ID_TOKEN}"
```

## Update Cloud Run to not allow unauthenticated access

```shell
export UI_URL=$(gcloud run services describe user-interface --format='value(status.url)')
export SKILL_LOOKUP_URL=$(gcloud run services describe skill-lookup --format='value(status.url)')
export FACT_SERVICE_URL=$(gcloud run services describe fact-service --format='value(status.url)')
```
