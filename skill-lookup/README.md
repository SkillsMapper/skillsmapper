# Skill Lookup

Create an environment variable to store the `SERVICE_NAME`:

```shell
export SERVICE_NAME=[SERVICE_NAME]
```

## Create a Service Account

Create an environment variable to store the `SERVICE_ACCOUNT_NAME`:

```shell
export SERVICE_ACCOUNT_NAME=[SERVICE_ACCOUNT_NAME]
```

Create a service account for the skill lookup service:

```shell
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
--display-name "Skill Lookup Service Account"
```

Grant the service account the `objectViewer` role for the bucket that contains `tags.csv`:

```shell
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com:objectViewer gs://$BUCKET_NAME
```

## Create a Cloud Run Service

Set the default region for Cloud Run:

```shell
gcloud config set run/region $REGION
```

Build and deploy the Cloud Run service:

```shell
gcloud run deploy $SERVICE_NAME --source . --env-vars-file=.env.yaml --service-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com --allow-unauthenticated
```

Set the `SERVICE_URL` environment variable:

```shell
export SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --format='value(status.url)')
```

Test with curl:

```shell
curl -X GET "${SERVICE_URL}/autocomplete?prefix=java"
```
