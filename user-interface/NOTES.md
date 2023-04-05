## TODO:

* Sort out bearer token

fact service should not allow unauthorized access and api gateway should have a service account

* put domain name in
* remove UIs from earlier services
* 
"With Cloud Functions, the identity token created contains automatically the correct audience. It's not the case when you invoke Cloud Run, you have to explicitly mention the Cloud Run audience"

* look at x-google-management:

* Expose all services under skillsmapper.org
* Backend services under api.skillsmapper.org

## Hosting as a Static Website
https://cloud.google.com/storage/docs/hosting-static-website
https://medium.com/google-cloud/google-cloud-run-or-how-to-run-your-static-website-in-5-minutes-and-much-more-dbe8f2804395

There are more scalable and cost-effective ways to host a UI on Google Cloud. In this chapter we will explore two options.

The first option is to use Google Cloud Run to host a UI. This is a serverless option that is cost-effective.

The second option is to use a Cloud Storage Bucket to host a UI. This is an even more cost-effective option.

We will also show how we can use Identify Platform to support authentication using Google Sign-In rather than using just a simple username and password.

https://cloud.google.com/load-balancing/docs/https/setting-up-https-serverless

https://cloud.google.com/api-gateway/docs/authenticating-users-firebase

https://medium.com/google-cloud/google-cloud-platform-api-gateway-d8eed0f2e024

https://619frank.medium.com/firebase-auth-api-gateway-cloud-function-f793fca3a37b

This one has a diagram of authentication flow
https://stackoverflow.com/questions/71782426/google-cloud-api-gateway-cant-invoke-cloud-run-service-while-using-firebase-aut

https://medium.com/@chamaln/setting-up-firebase-token-authentication-with-gcp-api-gateway-1a68578c1eca

### Debugging Auth

Direct to cloud run url:

"iss": "https://securetoken.google.com/skillsmapper-org",
"aud": "skillsmapper-org",

To gateway (get): 403

"aud": "skillsmapper-org",
"iss": "https://accounts.google.com"

Error when authenticating: Firebase ID token has incorrect \"iss\" (issuer) claim.

To gateway (post): 403

"aud": "https://fact-service-j7n5qulfna-uc.a.run.app",
"iss": "https://accounts.google.com",

Firebase ID token has incorrect \"aud\" (audience) claim

https://www.youtube.com/watch?v=BPGpdwPRP6I

If the service has not started:

{"message":"upstream request timeout","code":504}
