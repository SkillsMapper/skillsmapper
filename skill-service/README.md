# Skill Service

## Pre-requisites

First follow the instructions in the [Setup](../setup/README.md) to get a project up and running.

If returning to this project after installation, reinitalise environment variables using:

```shell
set -a; source ../.env; source .env; source .env.cloudbuild; set +a
```

## Installation

Create an environment variable to store the `SKILL_LOOKUP_SERVICE_NAME`:

```shell
export SKILL_LOOKUP_SERVICE_NAME=[SKILL_LOOKUP_SERVICE_NAME]
```

## Create a Service Account

Create an environment variable to store the `SKILL_LOOKUP_SERVICE_ACCOUNT_NAME`:

```shell
export SKILL_LOOKUP_SERVICE_ACCOUNT_NAME=[SKILL_LOOKUP_SERVICE_ACCOUNT_NAME]
```

Create a service account for the skill lookup service:

```shell
gcloud iam service-accounts create $SKILL_LOOKUP_SERVICE_ACCOUNT_NAME \
--display-name "Service account for ${SKILL_LOOKUP_SERVICE_NAME}"
```

Grant the service account the `objectViewer` role for the bucket that contains `tags.csv`:

```shell
gsutil iam ch serviceAccount:$SKILL_LOOKUP_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com:objectViewer gs://$BUCKET_NAME
```

Grant the service account the `logging.logWriter` role:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$SKILL_LOOKUP_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/logging.logWriter
```

## Create a Cloud Run Service

Set the default region for Cloud Run:

```shell
gcloud config set run/region $REGION
```

Build and deploy the Cloud Run service:

```shell
gcloud run deploy $SKILL_LOOKUP_SERVICE_NAME --source . --env-vars-file=.env.yaml --service-account $SKILL_LOOKUP_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --allow-unauthenticated
```

Set the `SKILL_LOOKUP_SERVICE_URL` environment variable:

```shell
export SKILL_LOOKUP_SERVICE_URL=$(gcloud run services describe $SKILL_LOOKUP_SERVICE_NAME --format='value(status.url)')
```

Test with curl:

```shell
curl -X GET "${SKILL_LOOKUP_SERVICE_URL}/autocomplete?prefix=java"
```

## Manual Build

```shell
 gcloud builds submit --config cloudbuild-cicd.yaml . --substitutions _REPOSITORY=SkillMapper,_SERVICE_NAME=skill-service,COMMIT_SHA=$(git rev-parse HEAD)
```
