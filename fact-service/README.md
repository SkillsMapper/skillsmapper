# Fact Service

This is a summary of [Chapter P3](../chapters/ch08a.asciidoc)

## Services Used

* Cloud Run
* Cloud SQL
* Secret Manager
* Identity Platform

## Local Development

Apply local .env:

```shell
set -a; source ../.env; source .env; set +a
```

### Run Locally

```shell
mvn spring-boot:run
```

### Building the Container Locally

Build the container locally using Jib:

```shell
./mvnw compile com.google.cloud.tools:jib-maven-plugin:2.4.0:build \
  -Dimage=gcr.io/${PROJECT_ID}/${FACT_SERVICE_NAME}
```

## Pre-requisites

First follow the instructions in the [Setup](../setup/README.md) to get a project up and running.

## Enable APIs

Enable the additional APIs for the services used in this project:

```shell
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

## Create a Cloud SQL Instance

Create an environment variable to store the `INSTANCE_NAME` e.g. `facts-postgresql`:

```shell
INSTANCE_NAME='[INSTANCE_NAME]'
```

Create a new Cloud SQL instance:

```shell
gcloud sql instances create $INSTANCE_NAME \
    --database-version=POSTGRES_14 \
    --tier=$DATABASE_TIER \
    --region=$REGION \
    --availability-type=REGIONAL \
    --storage-size=$DISK_SIZE
```

## Create a Cloud SQL Database

Create an environment variable to store the `DATABASE_NAME` e.g. `facts`:

```shell
export DATABASE_NAME='[DATABASE_NAME]'
```

Create a new database:

```shell
gcloud sql databases create $DATABASE_NAME \
    --instance=$INSTANCE_NAME
```

## Create a Cloud SQL User

Create an environment variable to store the `FACT_SERVICE_USER` e.g. `fact-service-user` and
a `FACT_SERVICE_PASSWORD`. I recommend using a password manager to generate a secure password.

```shell
export FACT_SERVICE_USER='[FACT_SERVICE_USER]'
export FACT_SERVICE_PASSWORD='[FACT_SERVICE_PASSWORD]'
```

Create a user for the instance with a username and password:

```shell
gcloud sql users create $FACT_SERVICE_USER \
    --instance=$INSTANCE_NAME \
    --password=$FACT_SERVICE_PASSWORD
```

### Allow connection from own network (optional)

To connect from your own network, you need to add a network to the instance. This is not required if
you are connecting from the same network as the Cloud SQL instance.

```shell
gcloud sql instances patch $INSTANCE_NAME \
    --authorized-networks=$MY_IP
```

## Add Secrets to Secrets Manager

Create a secret in Secrets Manager to store the database password:

```shell    
gcloud secrets create $FACT_SERVICE_DB_PASSWORD_SECRET_NAME \
    --replication-policy=automatic \
    --data-file=<(echo -n $DATABASE_PASSWORD)
```

NOTE: The `echo -n` is important as it removes the trailing newline character. With a newline the
database authentication will fail with `Prohibited character` error.

## Cloud Run

Create an environment variable to store the `FACT_SERVICE_NAME` e.g. `fact-service`:

```shell    
export FACT_SERVICE_NAME='[FACT_SERVICE_NAME]'
```

Deploy to Cloud Run:

```shell
gcloud run deploy $FACT_SERVICE_NAME --source . --env-vars-file=.env.yaml --allow-unauthenticated
```

Store the URL of the service in an environment variable:

```shell
export FACT_SERVICE_URL=$(gcloud run services describe $FACT_SERVICE_NAME --format='value(status.url)')
```

## Create a Service Account

Create a service account:

```shell
gcloud iam service-accounts create $FACT_SERVICE_SERVICE_ACCOUNT_NAME \
    --description="Service account for ${FACT_SERVICE_NAME}"
```

Grant the service account the `Cloud SQL Client` role:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$FACT_SERVICE_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/cloudsql.client
```

Grant the service account the `Secret Manager Secret Accessor` role:

```shell
gcloud secrets add-iam-policy-binding $FACT_SERVICE_DB_PASSWORD_SECRET_NAME \
--member=serviceAccount:$FACT_SERVICE_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
--role=roles/secretmanager.secretAccessor
```

## Connect to Cloud SQL

Update the Cloud Run service to connect to Cloud SQL and use the service account:

```shell
gcloud run services update $FACT_SERVICE_NAME \
    --service-account ${FACT_SERVICE_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --add-cloudsql-instances ${PROJECT_ID}:${REGION}:${INSTANCE_NAME} \
    --update-secrets=DATABASE_PASSWORD=${FACT_SERVICE_DB_PASSWORD_SECRET_NAME}:latest
```

Redeploy:

```shell
gcloud run deploy $FACT_SERVICE_NAME --source . --env-vars-file=.env.yaml \
--service-account ${FACT_SERVICE_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
--add-cloudsql-instances ${PROJECT_ID}:${REGION}:${INSTANCE_NAME} \
--update-secrets=DATABASE_PASSWORD=${FACT_SERVICE_DB_PASSWORD_SECRET_NAME}:latest
```

## Test with Curl

https://cloud.google.com/identity-platform/docs/sign-in-user-email

Store the API Key in an environment variable:

```shell
export API_KEY='[API_KEY]'
```

and the test email address and password:

```shell
export TEST_EMAIL='[TEST_EMAIL]'
export TEST_PASSWORD='[TEST_PASSWORD]'
```

```shell
curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}"
```

This will return a JSON response with the `idToken`:

Extract the idToken to an environment variable:

```shell
export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')
```

We can then use this token to access the API:

```shell
curl -X GET -H "Authorization: Bearer ${ID_TOKEN}" ${FACT_SERVICE_URL}/facts
```

For example, we can use this to submit a fact:

```shell
curl -X POST \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{ "skill": "java", "level": "learning" }`' \
  ${FACT_SERVICE_URL}/facts
```

This should return a `201` response with the fact that was created e.g.:

```json
{
  "id": 2,
  "timestamp": "2023-03-06T08:26:20.381966",
  "userUID": "v9qeph7MLBf5EgFYlUCKMTYwQ6i1",
  "level": "learning",
  "skill": "java"
}
```

## Check the Database

Connect to the database instance:

```shell
gcloud sql connect $INSTANCE_NAME --user=$FACT_SERVICE_DB_USER --database $DATABASE_NAME

```

Note: this also temporarily adds your IP address to the list of allowed IP addresses for the
instance.

## Identity Platform

From [https://cloud.google.com/run/docs/tutorials/identity-platform](https://cloud.google.com/run/docs/tutorials/identity-platform)

Enable the Identity Platform API:

```shell
gcloud services enable identityplatform.googleapis.com
```

Download the OAuth 2.0 Client ID:

```shell
gclo
```

## Database connection options



### Open API 

http://localhost:8080/v3/api-docs/




































































































































































































































































































































































































































































































































































































































































































































































































