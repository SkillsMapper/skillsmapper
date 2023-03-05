# Skaffold with Cloud Run

```shell
skaffold init
```

```shell
export PROJECT_ID=skillsmapper-dev
```

Switch to project
```shell
gcloud config set project $PROJECT_ID
```

Enable Cloud Run Admin API
```shell
gcloud services enable run.googleapis.com 
```

## Create API Gateway



## Create Load Balancer

```shell
gcloud beta compute network-endpoint-groups create SERVERLESS_NEG_NAME \
--region=REGION_ID \
--network-endpoint-type=serverless \
--serverless-deployment-platform=apigateway.googleapis.com \
--serverless-deployment-resource=GATEWAY_ID
```

To create a backend service, run the following command:
```shell
gcloud compute backend-services create BACKEND_SERVICE_NAME --global
```

add your serverless NEG as a backend to the backend service, run the following command, where:

```shell
gcloud compute backend-services add-backend BACKEND_SERVICE_NAME \
  --global \
  --network-endpoint-group=SERVERLESS_NEG_NAME \
  --network-endpoint-group-region=REGION_ID
```
