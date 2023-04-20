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

```shell
curl -s -X GET -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2ZGE4NmU4MWJkNTllMGE4Y2YzNTgwNTJiYjUzYjUzYjE4MzA3NzMiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiRGFuaWVsIFZhdWdoYW4iLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDMuZ29vZ2xldXNlcmNvbnRlbnQuY29tL2EvQUdObXl4Ym81UmJJZHF1d2l6NVhhV3JPYk5CdE96TlE0UVJMWUU5TUNVSkZQZDQ9czk2LWMiLCJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vc2tpbGxzbWFwcGVyLW9yZyIsImF1ZCI6InNraWxsc21hcHBlci1vcmciLCJhdXRoX3RpbWUiOjE2ODE3NjE4OTUsInVzZXJfaWQiOiJ1M1U1QnRKMkJSVzBmSzNMSnl3MHQyZENuYjMzIiwic3ViIjoidTNVNUJ0SjJCUlcwZkszTEp5dzB0MmRDbmIzMyIsImlhdCI6MTY4MTc2MTg5NSwiZXhwIjoxNjgxNzY1NDk1LCJlbWFpbCI6ImRhbmllbC52YXVnaGFuQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJmaXJlYmFzZSI6eyJpZGVudGl0aWVzIjp7Imdvb2dsZS5jb20iOlsiMTE2Mzg5NDA1ODA4MDc5NjE5OTQwIl0sImVtYWlsIjpbImRhbmllbC52YXVnaGFuQGdtYWlsLmNvbSJdfSwic2lnbl9pbl9wcm92aWRlciI6Imdvb2dsZS5jb20ifX0.cQSlFgIxNcRP-hW8uBQKo9y6e_djnjsFJKz7W8a2GzxCfjWtf4z1HnUIGa9jBXtOfQOBs0X7uwmw9UCIZzbBwFHq7PxYhWn4XbRhs1SNbZVkfjCGJ-xt9dH_k5pSgPddaZsXA7Y66BAzrznz6FRGfYHcKk1iiIt3clqVzhUhzO-J6QeGptMXQUVy_inhdmBIUzgqPwAQnNL79TxjoKsOsqmYMK4X7sQHRZJvtJ9-5MbXgseWUpcgTNSMLrIiBzo8Q4G-RVDV97tv8Hbk94djbBLqg97EoQhUwLz5tpfHwhdyoX4JjMI0NQx_NMsbL0e5ziw5a-BJsIytUhBrkFUadQ" "http://localhost:8080/profiles/me"
```