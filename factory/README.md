# Chapter 11 - Factory

## Prerequisites

```shell
set -a; source ../.env; source .env; set +a
```

## Replicate the Projects in Code Repository

You don't need to move your code into Google Cloud Source Repository, but you do need to replicate the projects in the
repository so it is available to the likes of Google Cloud Build. Unfortunately, at the time of writing there is no way
to do this via the command line, so you will need to do this manually:

* In the Google Cloud console, open Cloud Source Repositories.
* Click Add repository.
* Select Connect external repository and click Continue.
* In the Project drop-down list, select the Google Cloud project to which the mirrored repository belongs.
* In the Git provider drop-down list, select GitHub.
* Click Connect to GitHub.
* Sign in to GitHub with your machine user credentials.
* Click Authorize GoogleCloudPlatform.
* When authorization finishes, you're returned to the Connect external repository page. A list of repositories opens.
* From the list of repositories, select the repository you want to mirror.

To list respositories in Google Cloud Source Repository:

```shell    
gcloud source repos list
```

Then push the code to the repository:

```shell    

```

## Cloud Build

Enable Cloud Build:

```shell
gcloud service enable cloudbuild.googleapis.com
```

### Export a build

List existing builds:

```shell
gcloud builds list
```

Export a build:

```shell
gcloud builds describe 669b066c-9154-42c2-bf51-68d3baeee7e2 --format yaml > ../skill-lookup/cloudbuild.yaml
```

### Use pack to build locally

```shell
 pack build -B gcr.io/buildpacks/builder:v1 --builder gcr.io/buildpacks/builder:v1 --publish gcr.io/$PROJECT_ID/skill-service
```

### Define a build

Create a `cloudbuild.yaml` file for the service which uses pack. This requires Docker to be installed on your local
machine.

### Trigger a build manually

Run a build on Cloud Build. This builds in Google Cloud so does not require Docker to be running locally. The local code is used.

```shell
gcloud builds submit --config cloudbuild.yaml .
```

### Trigger a build and push automatically

To trigger a build when a change is made to the `main` branch of the repository:

```shell
gcloud beta builds triggers create cloud-source-repositories \
  --repo=$REPO_NAME \
  --branch-pattern=main \
  --build-config=cloudbuild.yaml
```

### Comparison

|       | Pack  | Cloud Build | Cloud Build Trigger |
|-------|-------|-------------|---------------------|
| Code  | Local | Local       | Remote              |
| Build | Local | Remote      | Remote              |


## Terraform

Starting for provider.tf

Use Terraform to deploy the infrastructure.

## Cloud Deploy

Enable Cloud Deploy:

```shell
gcloud services enable clouddeploy.googleapis.com
```

Create a Cloud Deploy for the Cloud Run applications

```shell
https://cloud.google.com/deploy/docs/deploy-app-run
```


