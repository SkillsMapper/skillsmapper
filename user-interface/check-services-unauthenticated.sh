#!/bin/bash
SERVICES=$(gcloud run services list --platform managed --project $PROJECT_ID --region $REGION --format 'value(metadata.name)')

for SERVICE in $SERVICES
do
  echo "Checking service $SERVICE..."
  POLICY=$(gcloud run services get-iam-policy $SERVICE --platform managed --project $PROJECT_ID --region $REGION)
  if echo "$POLICY" | grep -q "allUsers"; then
    echo "$SERVICE is publicly accessible"
  else
    echo "$SERVICE is not publicly accessible"
  fi
done
