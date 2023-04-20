# Skills Mapper User Interface

## Run Locally

Apply local .env:

```shell
set -a; source ../.env; set +a 
set -a; source .env; set +a
```

## Exposing the Backend

Updating docs:

```shell
swagger-codegen generate -i api.yaml -l html2 -o ./src/api-docs
```

Generate config.js:

```shell
envsubst < config.js.template > src/js/config.js
```

## Hosting with Cloud Run

```shell
gcloud builds submit --tag gcr.io/${PROJECT_ID}/user-interface
```

```shell
gcloud run deploy user-interface --image gcr.io/${PROJECT_ID}/user-interface
```

Get the endpoint:
```shell
gcloud run services describe user-interface --platform managed --region europe-west2 --format 'value(status.url)'
```

## Get the endpoints

```shell
export FACT_SERVICE_URL=$(gcloud run services describe ${FACT_SERVICE_NAME} --format 'value(status.url)')
export SKILL_SERVICE_URL=$(gcloud run services describe ${SKILL_SERVICE_NAME} --format 'value(status.url)')
export PROFILE_SERVICE_URL=$(gcloud run services describe ${PROFILE_SERVICE_NAME} --format 'value(status.url)')
export UI_SERVICE_URL=$(gcloud run services describe ${UI_SERVICE_NAME} --format 'value(status.url)')
```

Create an api.yaml file from the `api.yaml.template` file:

```shell
envsubst < api.yaml.template > api.yaml
```

## Create an API Gateway

Enable API Gateway and Service Control

```shell
gcloud services enable apigateway.googleapis.com
gcloud services enable servicecontrol.googleapis.com
```

```shell
export API_NAME=skillsmapper
export API_SPEC_FILE=api.yaml
```

Create both an API and an API Config:

```shell
gcloud api-gateway api-configs create ${API_NAME}-config \
  --api=${API_NAME} \
  --openapi-spec=${API_SPEC_FILE} \
  --project=${PROJECT_ID}
```

Delete the API Config with an updated spec:

```shell
gcloud api-gateway api-configs delete ${API_NAME}-config \
  --api=${API_NAME} \
  --project=${PROJECT_ID}
```

## Create a Service Account

Create a service account with permission to invoke the Cloud Run service:

```shell
gcloud iam service-accounts create "${API_NAME}-gateway-sa" \
  --display-name "Service account to invoke ${API_NAME} services"
```

Add Cloud Run Invoker role to the service account:

```shell
gcloud run services add-iam-policy-binding $FACT_SERVICE_NAME \
  --role roles/run.invoker \
  --member "serviceAccount:${API_NAME}-gateway-sa@${PROJECT_ID}.iam.gserviceaccount.com"
```

## Create a Gateway

Create an API Gateway:

```shell
gcloud api-gateway gateways create ${API_NAME}-gateway \
  --api=${API_NAME} \
  --api-config=${API_NAME}-config \
  --location=${REGION} \
  --project=${PROJECT_ID}
```

Delete the gateway:
```shell
gcloud api-gateway gateways delete ${API_NAME}-gateway \
  --location=${REGION} \
  --project=${PROJECT_ID}
```

Get the URL:
```shell
export GATEWAY_URL=$(gcloud api-gateway gateways describe skillsmapper-gateway --location=${REGION} --project=${PROJECT_ID} --format 'value(defaultHostname)')
```

### Remove allow unauthenticated

Prevent unauthenticated access to the Cloud Run service:

```shell
gcloud run services update $FACT_SERVICE_NAME \
    --allow-unauthenticated=false
```

### Add endpoint to Authentication

Add to Settings>Authorized Domains:

skillsmapper-gateway-7dehhhx6.uc.gateway.dev


### UI

```shell
curl -X GET "https://${GATEWAY_URL}"
```

### Skills

Direct:
```shell
curl -X GET "${SKILL_LOOKUP_URL}/autocomplete?prefix=java"
````

Via gateway
```shell
curl -X GET "https://${GATEWAY_URL}/skills/autocomplete?prefix=java"
```

Via domain
```shell
curl -X GET "https://${DOMAIN}/skills/autocomplete?prefix=java"
```

### Facts

#### Get a Token

Get a token to test the secured endpoints:

```shell
export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')
```

#### Test Token

Decode a token by pasting the value of `echo $ID_TOKEN` into the following site:

```shell
https://jwt.io/
```

This will decode the token and show the claims. The `aud` claim should be the project ID and the `iss` claim should be `https://securetoken.google.com/${PROJECT_ID}`.

Test the endpoint:

```shell
export ID_TOKEN=$(curl "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}" \
-H "Content-Type: application/json" \
--data-binary "{\"email\":\"${TEST_EMAIL}\",\"password\":\"${TEST_PASSWORD}\",\"returnSecureToken\":true}" | jq -r '.idToken')
```

### GET

```shell
curl -X GET "https://${GATEWAY_URL}/facts" \
  -H "Authorization: Bearer ${ID_TOKEN}"
```

```shell
curl -X GET "https://${DOMAIN}/facts" \
  -H "Authorization: Bearer ${ID_TOKEN}"
```

### POST

```shell
curl -X POST \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{ "skill": "java", "level": "learning" }`' \
  https://${GATEWAY_URL}/facts
```

```shell
curl -X POST \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{ "skill": "java", "level": "learning" }`' \
  https://${DOMAIN}/facts
```
### DELETE

Gateway:

```shell
curl -X DELETE \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  ${GATEWAY_URL}/facts/1
```
Domain:

```shell
curl -X DELETE \
  -H "Authorization: Bearer ${ID_TOKEN}" \
  ${DOMAIN}/facts/1
```

### Troubleshooting

"Jwt issuer is not configured" - x-google-audiences is not set


With Cloud Functions, the identity token created contains automatically the correct audience. It's not the case when you invoke Cloud Run, you have to explicitly mention the Cloud Run audience.

Although documentation say:

"If an operation uses x-google-backend but does not specify either jwt_audience or disable_auth, ESPv2 will automatically default the jwt_audience to match the address. If address is not set, ESPv2 will automatically set disable_auth to true."

This is only true for Cloud Functions not Cloud Run.

"message" : "Error when authenticating: Firebase ID token has incorrect \"aud\" (audience) claim. Expected \"skillsmapper-org\" but got \"https://fact-service-j7n5qulfna-uc.a.run.app\". Make sure the ID token comes from the same Firebase project as the service account used to authenticate this SDK. See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token.",

"message" : "Error when authenticating: Firebase ID token has incorrect \"iss\" (issuer) claim. Expected \"https://securetoken.google.com/skillsmapper-org\" but got \"https://accounts.google.com\". Make sure the ID token comes from the same Firebase project as the service account used to authenticate this SDK. See https://firebase.google.com/docs/auth/admin/verify-id-tokens for details on how to retrieve an ID token.",

If a gateway's request to your Cloud Run service is rejected, ensure that the gateway's service account is granted the roles/run.invoker role, and that the gateway's service account has the run.routes.invoke permission. Learn more about the invoker roles and permissions in the Cloud Run IAM reference.

API Gateway will send the authentication result in the X-Apigateway-Api-Userinfo to the backend API. It is recommended to use this header instead of the original Authorization header. This header is base64url encoded and contains the JWT payload.

## Update Cloud Run to not allow unauthenticated access

# Put a real domain

## Create Backend

```shell
export PREFIX=skillsmapper
```

### Global IP address

Reserve a global ip address:

```shell
gcloud compute addresses create ${PREFIX}-ip --global
```

### Create an SSL Certificate

```shell
export DOMAIN=skillsmapper.org
```

```shell
gcloud compute ssl-certificates create ${PREFIX}-cert \
--domains=$DOMAIN
```

Check status:

```shell
gcloud compute ssl-certificates describe ${PREFIX}-cert
```

### Create the load balancer

Create a serverless NEG

```shell
gcloud beta compute network-endpoint-groups create ${PREFIX}-api-gateway-serverless-neg \
   --region=$REGION \
   --network-endpoint-type=serverless \
   --serverless-deployment-platform=apigateway.googleapis.com \
   --serverless-deployment-resource=${PREFIX}-gateway 
````

Create a backend service

```shell
gcloud compute backend-services create ${PREFIX}-backend \
  --load-balancing-scheme=EXTERNAL \
  --global
```

Add the serverless NEG as a backend to the backend service:

```shell
gcloud compute backend-services add-backend ${PREFIX}-backend \
--global \
--network-endpoint-group=${PREFIX}-api-gateway-serverless-neg  \
--network-endpoint-group-region=${REGION}
```

Create a URL map to route incoming requests to the backend service:

```shell
gcloud compute url-maps create ${PREFIX}-url-map \
--default-service=${PREFIX}-backend
```

Create a target HTTP(S) proxy to route requests to your URL map.

```shell
gcloud compute target-https-proxies create ${PREFIX}-https-proxy \
    --url-map=${PREFIX}-url-map \
    --ssl-certificates=${PREFIX}-cert
```

Create a forwarding rule to route incoming requests to the proxy

```shell
 gcloud compute forwarding-rules create ${PREFIX}-fw \
   --load-balancing-scheme=EXTERNAL \
   --network-tier=PREMIUM \
   --address=${PREFIX}-ip \
   --target-https-proxy=${PREFIX}-https-proxy \
   --global \
   --ports=443
```

### Backend for a Bucket

https://cloud.google.com/load-balancing/docs/https/setup-global-ext-https-buckets

* Create a bucket

```shell
gsutil mb -p ${PROJECT_ID} -c regional -l ${REGION} gs://${PREFIX}-ui
```

* Upload the static files to the bucket
```shell
gsutil cp -r ./src/* gs://${PREFIX}-ui
```

Grant permissions to the bucket

```shell
gsutil iam ch allUsers:objectViewer gs://${PREFIX}-ui
```

View the bucket:

```shell
open https://storage.googleapis.com/${PREFIX}-ui/index.html
```

Create a backend for bucket

```shell
gcloud compute backend-buckets create ${PREFIX}-ui \
    --gcs-bucket-name=${PREFIX}-ui
```

Create a URL map to route incoming requests to the backend service:


```shell
gcloud compute url-maps create ${PREFIX}-with-ui 
--default-backend-bucket=${PREFIX}-ui
```

Add map for the api:

```shell
gcloud compute url-maps add-path-matcher ${PREFIX}-with-ui \
--default-backend-bucket=${PREFIX}-ui \
--path-matcher-name api-path-matcher \
--path-rules "/api/*=${PREFIX}-backend"
```