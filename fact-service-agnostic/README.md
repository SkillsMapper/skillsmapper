# Fact Service - Agnostic

This is a summary of [Chapter P4](../chapters/chp4.asciidoc)

## Run Locally

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

## Create a Secret

```shell
gcloud secrets create $FACT_SERVICE_DB_PASSWORD_SECRET_NAME \
  --replication-policy=automatic \
  --project=$PROJECT_ID
```

```shell
```

## Create Service Account

```shell
export FACT_SERVICE_SERVICE_ACCOUNT_NAME=fact-service-sa
```

```shell
gcloud iam service-accounts create $FACT_SERVICE_SERVICE_ACCOUNT_NAME \
  --project=$PROJECT_ID
```

Use the same service account as last time

### Link the service account

Bind the Kubernetes service account to the Google service account with the `iam.workloadIdentityUser` role:

```shell
gcloud iam service-accounts add-iam-policy-binding GSA_NAME@GSA_PROJECT.iam.gserviceaccount.com \
--role roles/iam.workloadIdentityUser \
--member "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"
```

Annotated the Kubernetes service account with the Google service account:
```shell
kubectl annotate serviceaccount gke-sa iam.gke.io/gcp-service-account=gke_service_account@${PROJECT_ID}.iam.gserviceaccount.com
```

## Deploy using Skaffold

Set the Skaffold default repo:

```shell
export SKAFFOLD_DEFAULT_REPO=gcr.io/$PROJECT_ID
```

Build and deploy the application using Skaffold:

```shell
skaffold run
```

```shell
cat *.yaml | envsubst
```

## Debugging

### Service Account Linking

The Kubernetes deployments use workload identity to link the Kubernetes service account to the Google service account.

To check the service account is linked correctly deploy the test pod:

```shell
kubectl apply -f workload-identity-test.yaml
```

Then exec into the pod:

```shell
kubectl exec -it workload-identity-test --namespace deduper -- /bin/bash
```

Then run the following command:
