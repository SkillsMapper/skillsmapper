# Profile Builder

## Pre-requisites

```shell
set -a # automatically export all variables
source ../.env
source .env
set +a
```

## Create a topic

Create a topic to send events to:

```shell
gcloud pubsub topics create $FACT_CHANGED_TOPIC
```

## Send Event
Revisiting the fact service, add a new class to send the notification

Add pubsub to `pom.xml`:

```xml
<dependency> 
    <groupId>org.springframework.cloud</groupId> 
    <artifactId>spring-cloud-gcp-starter-pubsub</artifactId> 
    <version>2.0.7</version> 
</dependency>
```

## Deploy to Cloud Run

Create an environment variable to store the `PROFILE_SERVICE_NAME` e.g. `profile-builder':

```shell
export PROFILE_SERVICE_NAME=[PROFILE_SERVICE_NAME]
```
Build and deploy the Cloud Run service:

```shell
gcloud run deploy $PROFILE_SERVICE_NAME --source . --env-vars-file=.env.yaml --allow-unauthenticated
```

Set the `PROFILE_SERVICE_URL` environment variable. We will use this to configure the Pub Sub subscription:

```shell
export PROFILE_SERVICE_URL=$(gcloud run services describe $PROFILE_SERVICE_NAME --format='value(status.url)')
```

## Create a subscription

Create a dead letter topic to send failed events to:

```shell
gcloud pubsub topics create $FACT_CHANGED_TOPIC-deadletter
```

Create a push subscription receive events from:

```shell
gcloud pubsub subscriptions create $FACT_CHANGED_SUBSCRIPTION --topic $FACT_CHANGED_TOPIC --push-endpoint $PROFILE_SERVICE_NAME --max-delivery-attempts=5 --dead-letter-topic=$FACT_CHANGED_TOPIC-deadletter
```

* Don't want to keep trying, go to dead letter queue with exponential backoff

Delete subscription if failing repeatedly:

```shell
gcloud pubsub subscriptions delete $FACT_CHANGED_SUBSCRIPTION 
```
## Receive Event

## Query Service

## Create Profile

Enable the firestore api:

```shell
gcloud services enable firestore.googleapis.com
```

Create a firestore database:

```shell
gcloud alpha firestore databases create --location=$REGION --database=$DATABASE_NAME --type=datastore-mode
```

```shell
gcloud alpha firestore databases update --type=firestore-native
```

NOTE: you can only have one firestore/datastore database per project

## Write to Firestore

## Read from Firestore
