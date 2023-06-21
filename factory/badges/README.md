# Creating Badges for Cloud Build

Based on https://github.com/kelseyhightower/badger

Set the PROJECT_ID environment variable to your management project e.g. `skillsmapper-management`.

```shell
export PROJECT_ID=[MANAGEMENT_PROJECT_ID]
```

Set the region environment variable to the region you want to deploy the Cloud Run service to e.g. `europe-west2`.

```shell
export REGION=[REGION]
```

Set the project to your management project.

```shell
gcloud config set project $PROJECT_ID
```

Enable the Cloud Run Service:

```shell
gcloud services enable run.googleapis.com
```

Download the Code

```shell
git clone https://github.com/kelseyhightower/badger
```

From the directory run Cloud Build substituting the tag name with your own.

```shell
gcloud builds submit --config cloudbuild.yaml . --substitutions=TAG_NAME=0.0.1
```

Create a badger service account and grant it the roles/cloudbuild.builds.viewer IAM role.

```shell
gcloud iam service-accounts create badger
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member serviceAccount:badger@${PROJECT_ID}.iam.gserviceaccount.com \
--role roles/cloudbuild.builds.viewer
```

Deploy the gcr.io/hightowerlabs/badger:0.0.1 container to Cloud Run.

```shell
gcloud run deploy badger \
--allow-unauthenticated \
--service-account "badger@${PROJECT_ID}.iam.gserviceaccount.com" \
--concurrency 80 \
--cpu 1 \
--image gcr.io/${PROJECT_ID}/badger:0.0.1 \
--memory '128Mi' \
--platform managed \
--region $REGION
```

## Test the Installation

Retrieve the badger Cloud Run service url:

```shell
export BADGER_ENDPOINT=$(gcloud run services describe badger \
--platform managed \
--region $REGION \
--format 'value(status.url)')
```
```shell
export TRIGGER_NAME="skill-service-trigger"
```

```shell
export TRIGGER_ID=$(gcloud beta builds triggers describe ${TRIGGER_NAME} --region $REGION --format='value(id)')
```
Retrieve the service URL associated with your badger deployment:

```shell
BADGER_ENDPOINT=$(gcloud run services describe badger \
--platform managed \
--region $REGION \
--format 'value(status.url)')
```

Construct an image URL using the badger service URL, trigger id, and project id. Example:

```shell
export BADGE_URL=${BADGER_ENDPOINT}'/build/status?project='${PROJECT_ID}'&id='${TRIGGER_ID}
```

Construct an image URL using the badger service URL, trigger id, and project id. Example:

```shell
echo ${BADGER_ENDPOINT}'/test/build/status?project='${PROJECT_ID}'&id='${TRIGGER_ID}
```

