# Fact Service - Agnostic

This is a summary of [Chapter P4](../chapters/chp4.asciidoc)

## Build Locally

Apply local .env:

```shell
set -a; source ../.env; set +a 
set -a; source .env; set +a
```

```shell
mvn spring-boot:run
```

Extract the idToken to an environment variable:

```shell
export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')
```

Set the fact service URL to the local URL:

```shell
export FACT_SERVICE_URL=http://localhost:8080
```

For example, we can use this to submit a fact:

```shell
curl -X POST \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{ "skill": "java", "level": "learning" }`' \
  ${FACT_SERVICE_URL}/facts
```

We can then use this token to access the API:

```shell
curl -X GET -H "Authorization: Bearer ${ID_TOKEN}" ${FACT_SERVICE_URL}/facts
```

## Create a GKE Autopilot Cluster

Enable the Kubernetes Engine API:

```shell
gcloud services enable container.googleapis.com
```

Create a GKE Autopilot cluster:

```shell
gcloud container clusters create-auto $PROJECT_ID-gke \
  --project=$PROJECT_ID \
  --region=$REGION
```

This will take a few minutes to create. On completion the cluster will be added to the kubeconfig file.

```shell
gcloud container clusters get-credentials $PROJECT_ID-gke --region $REGION --project $PROJECT_ID
```

## Deploy using Skaffold

Set the Skaffold default repo:

```shell
export SKAFFOLD_DEFAULT_REPO=gcr.io/$PROJECT_ID
```
