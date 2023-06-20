# Skill Service

## Pre-requisites

First follow the instructions in the [setup](../setup/README.md) to get a project up and running.

If you are returning to this project after installation and have saved all environment variables in `.env` reinitialise environment variables using:

```shell
set -a; source ../.env; source .env ;set +a
```

Then set the project to the current project:

```shell
gcloud config set project $PROJECT_ID
```

## Installation

Create an environment variable to store the `SKILL_SERVICE_NAME` e.g. `skill-service`:

```shell
export SKILL_SERVICE_NAME=[SKILL_SERVICE_NAME]
```

## Create a Service Account

Create an environment variable for the name of the service account `SKILL_SERVICE_SA` e.g. `skill-service-sa`:

```shell
export SKILL_SERVICE_SA=[SKILL_SERVICE_SA]
```

Create a service account for the Skill Service:

```shell
gcloud iam service-accounts create ${SKILL_SERVICE_SA} \
  --display-name "Service account for ${SKILL_SERVICE}"
```

Grant the service account the `objectViewer` role for the bucket that contains `tags.csv`:

```shell
gsutil iam ch serviceAccount:$SKILL_SERVICE_SA@$PROJECT_ID.iam.gserviceaccount.com:objectViewer gs://$BUCKET_NAME
```

Grant the service account the `logging.logWriter` role:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SKILL_SERVICE_SA@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/logging.logWriter
```

## Create a Cloud Run Service

Set the default region for Cloud Run:

```shell
gcloud config set run/region $REGION
```

Build and deploy the Cloud Run service:

```shell
gcloud run deploy $SKILL_SERVICE_NAME --source . --env-vars-file=.env.yaml --service-account $SKILL_SERVICE_SA@$PROJECT_ID.iam.gserviceaccount.com --allow-unauthenticated
```

Set the `SKILL_SERVICE_URL` environment variable:

```shell
export SKILL_SERVICE_URL=$(gcloud run services describe $SKILL_SERVICE_NAME --format='value(status.url)')
```

Test with curl:

```shell
curl -X GET "${SKILL_SERVICE_URL}/autocomplete?prefix=java"
```

## Manual Trigger Cloud Build

To manually trigger Cloud Build:

```shell
gcloud builds submit --config cloudbuild.yaml . --substitutions _REPOSITORY=$GIT_REPOSITORY,_SERVICE_NAME=$SKILL_SERVICE_NAME,COMMIT_SHA=$(git rev-parse HEAD)
```
