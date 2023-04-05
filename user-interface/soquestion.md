I am attempting to set up an API Gateway in front of a Cloud Run service that uses Firebase authentication.

Calling the Cloud Run function directly works fine. Looking at the JWT token received from the service I see it the aud and iss are as follows:

```
"iss": "https://securetoken.google.com/${PROJECT_ID}",
"aud": "${PROJECT_ID}",
```

However if I put it behind a gateway with a configuration like this:

```code
security:
  - firebase: []
securityDefinitions:
  firebase:
    authorizationUrl: ""
    flow: "implicit"
    type: "oauth2"
    x-google-issuer: "https://securetoken.google.com/${PROJECT_ID}"
    x-google-jwks_uri: "https://www.googleapis.com/service_accounts/v1/metadata/x509/securetoken@system.gserviceaccount.com"
    x-google-audiences: ${PROJECT_ID}
...

  /:
    get:
      summary: My Service
      operationId: myService
      x-google-backend:
        address: ${CLOUD_RUN_SERVICE URL}
        jwt_audience: ${PROJECT_ID}
      security:
        - firebase: [ ]
```
