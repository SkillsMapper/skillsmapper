# Tag Updater

This is a summary of [Chapter P1](../chapters/chp1.asciidoc)

## Pre-requisites

Create a new project and enable billing as described in the [Setup](../setup/README.md) instructions.

## Enable APIs

Enable the APIs for the services used in this project:

```shell
gcloud services enable \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  run.googleapis.com \
  cloudscheduler.googleapis.com
```

## Create a Cloud Storage Bucket

Create an environment variable to store the `BUCKET_NAME` e.g. `[PROJECT_ID]-tags`:

```shell
export BUCKET_NAME='[BUCKET_NAME]'
```

Create a new bucket:

```shell
gsutil mb gs://${BUCKET_NAME}
```

Create an environment variable to store the `OBJECT_NAME` e.g. `tags.csv`:

```shell
export OBJECT_NAME='[OBJECT_NAME]'
```

## Create a Cloud Function Service Account

Create an environment variable to store the `SERVICE_ACCOUNT_NAME` e.g. `tag-updater-sa`:

```shell
export SERVICE_ACCOUNT_NAME='[SERVICE_ACCOUNT_NAME]'
```

Create the service account:

```shell
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
--display-name "Tag Updater Service Account"
```

Grant the service account the `bigquery.jobUser` role:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/bigquery.jobUser
```

Grant the service account the `storage.objectAdmin` role:

```shell
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com:objectAdmin gs://$BUCKET_NAME
```

## Deploy a Cloud Function

Create an environment variable to store the default `REGION` for Cloud Functions e.g. `us-central1`:

```shell
export REGION='[REGION]'
```

Set the default region for Cloud Functions:

```shell
gcloud config set functions/region $REGION
```
Set an environment variable to store the `CLOUD_FUNCTION_NAME` e.g. `tag-updater`:

```shell
export CLOUD_FUNCTION_NAME='[FUNCTION_NAME]'
```

Deploy the Cloud Function:

```shell
gcloud functions deploy $CLOUD_FUNCTION_NAME \
--gen2 \
--runtime=go119 \
--service-account="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
--trigger-http \
--no-allow-unauthenticated \
--env-vars-file .env.yaml
```

Store the URI of the Cloud Function in an environment variable:

```shell
export CLOUD_FUNCTION_URI=$(gcloud functions describe $CLOUD_FUNCTION_NAME --gen2 --format='value(serviceConfig.uri)')
```

Test the Cloud Function:

```shell
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $CLOUD_FUNCTION_URI
```

## Create a Cloud Function Invoker Service Account

## Create a Cloud Scheduler Job

Create an environment variable to store the `JOB_NAME` e.g. `tag-updater-job`:

```shell
JOB_NAME='[JOB_NAME]'
```
