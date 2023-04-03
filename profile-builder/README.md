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

```shell
export PROFILE_BUILDER_SERVICE_NAME=[PROFILE_BUILDER_SERVICE_NAME]
```

Build and deploy the Cloud Run service:

```shell
gcloud run deploy $PROFILE_BUILDER_SERVICE_NAME --source . --env-vars-file=.env.yaml --allow-unauthenticated
```

Set the `SKILL_LOOKUP_SERVICE_URL` environment variable:

```shell
export PROFILE_BUILDER_SERVICE_URL=$(gcloud run services describe $PROFILE_BUILDER_SERVICE_NAME --format='value(status.url)')
```

## Create a subscription

Create a deadletter topic to send failed events to:

```shell
gcloud pubsub topics create $FACT_CHANGED_TOPIC-deadletter
```

Create a push subscription receive events from:

```shell
gcloud pubsub subscriptions create $FACT_CHANGED_SUBSCRIPTION --topic $FACT_CHANGED_TOPIC --push-endpoint $PROFILE_BUILDER_SERVICE_URL --max-delivery-attempts=5 --dead-letter-topic=$FACT_CHANGED_TOPIC-deadletter
```

* Don't want to keep trying, go to dead letter queue with exponential backoff

Delete subscription if failing repeatedly:

```shell
gcloud pubsub subscriptions delete $FACT_CHANGED_SUBSCRIPTION 
```

## Receive Event

## Query Service

## Create Profile

## Write to Firestore

## Read from Firestore
