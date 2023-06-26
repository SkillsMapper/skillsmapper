#!/bin/bash
echo "Enabling services for project ${MANAGEMENT_PROJECT_ID}"
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  --project=${MANAGEMENT_PROJECT_ID}

echo "Enabling services for project ${DEV_PROJECT_ID}"
gcloud services enable \
  apigateway.googleapis.com \
  artifactregistry.googleapis.com \
  bigquery.googleapis.com \
  cloudbuild.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudscheduler.googleapis.com \
  compute.googleapis.com \
  firestore.googleapis.com \
  identitytoolkit.googleapis.com \
  pubsub.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  servicecontrol.googleapis.com \
  servicenetworking.googleapis.com \
  sqladmin.googleapis.com \
  --project=${DEV_PROJECT_ID}
