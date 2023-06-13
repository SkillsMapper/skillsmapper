# Chapter 11 — Factory

## Prerequisites

```shell
set -a; source ../.env; source .env; set +a
```

## Replicate the Projects in Code Repository

You don't need to move your code into Google Cloud Source Repository, but you do need to replicate the projects in the
repository, so it is available to the likes of Google Cloud Build. Unfortunately, at the time of writing, there is no way
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

To list repositories in Google Cloud Source Repository:

```shelset -a; source ../.env; source .env; set +al    
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
gcloud builds describe 669b066c-9154-42c2-bf51-68d3baeee7e2 --format yaml > ../skill_service/cloudbuild-go.yaml
```

### Use pack to build locally

```shell
 pack build -B gcr.io/buildpacks/builder:v1 --builder gcr.io/buildpacks/builder:v1 --publish gcr.io/$PROJECT_ID/skill_service
```

### Define a build

Create a `cloudbuild.yaml` file for the service which uses pack. This requires Docker to be installed on your local
machine.

```yaml
steps:
  - args:
      - build
      - gcr.io/$PROJECT_ID/skill_service
      - --network
      - cloudbuild
      - --builder
      - gcr.io/buildpacks/builder
    entrypoint: pack
    name: gcr.io/k8s-skaffold/pack
    dir: skill_service
```

* `args` - the arguments to pass to the `pack` command
* `network` - the network to use when building the container. The `cloudbuild` network has access to the Google Artifact Registry.
* `builder` - the builder to use. This is the Google Cloud builder which has access to the Google Artifact Registry.

By default Cloud Build uses a machine type with 1 CPU. This can be increased to 8 CPUs by adding the following to the
`cloudbuild.yaml` file:

```yaml
options:
  machineType: E2_HIGHCPU_8
```

### Trigger a build manually

Run a build on Cloud Build. This builds in Google Cloud so does not require Docker to be running locally. The local code is used.

```shell
export COMMIT_SHA=$(git rev-parse HEAD)
```

```shell
export RELEASE_TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
```

```shell
gcloud builds submit \
  --config cloudbuild.yaml \
  --substitutions=_RELEASE_TIMESTAMP=${RELEASE_TIMESTAMP} .
```

### Trigger a build and push automatically

To trigger a build when a change is made to the `main` branch of the repository:

```shell
gcloud beta builds triggers create cloud-source-repositories \
  --name=${SKILL_SERVICE_NAME} \
  --repo=$REPO_NAME \
  --branch-pattern=main \
  --build-config=${SKILL_SERVICE_NAME}/cloudbuild.yaml
```
### Comparison

|       | Pack  | Cloud Build | Cloud Build Trigger |
|-------|-------|-------------|---------------------|
| Code  | Local | Local       | Remote              |
| Build | Local | Remote      | Remote              |

https://medium.com/digio-australia/building-a-robust-ci-pipeline-for-golang-with-google-cloud-build-4b5029617bc9

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
gcloud deploy apply \
  --file=clouddeploy.yaml \
  --region=${REGION} \
  --project=${PROJECT_ID}
```

Get project number:

```shell
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
```

Add permissions to the Cloud Build account:

```shell
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/clouddeploy.operator
```

```shell
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser
```

```shell
https://cloud.google.com/deploy/docs/deploy-app-run
```

[Google Code Lab](https://codelabs.developers.google.com/cloud-run-app-deployment-with-cloud-deploy#2)

```shell
env subst < ./factory/ > cloudbuild-go.yaml
```

```shell
``` 

## Terraform

Lint

```shell
tflint ./...
```

```shell
tfsec
```

## Prerequisites

### Create the project

### Configure Identity Platform

* Enable Identity Platform in the marketplace
* Enable Identity Toolkit API

### Build Images

```shell
gcloud builds submit --pack image=gcr.io/${PROJECT_ID}/skill-service:latest ../skill-service
gcloud builds submit --pack image=gcr.io/${PROJECT_ID}/fact-service:latest ../fact-service
gcloud builds submit --pack image=gcr.io/${PROJECT_ID}/profile-service:latest ../profile-service
```

### Run Terraform

```shell
terraform apply
```
When rerunning manually, delete gateway and gateway config first:

```shell
gcloud api-gateway gateways delete ${API_NAME}-gateway \
--location=${REGION} \
--project=${PROJECT_ID}
```

```shell
gcloud api-gateway api-configs delete ${API_NAME}-api-gw-config --api ${API_NAME}-api-gw
```

### Run Infracost

```shell
infracost breakdown --path .
```

Add usage estimates: https://www.infracost.io/docs/features/usage_based_resources/

## Clearing up

Get the current project:

```shell
PROJECT_ID=$(gcloud config get-value project)
```

Delete the project:

```shell
gcloud projects delete ${PROJECT_ID}
```

Delete any remaining child resources:

```shell
gcloud endpoints services delete skillsmapper-api-api-gw-3pr8jbeyvvobi.apigateway.sm-terraform-test.cloud.goog --project=sm-terraform-test
```

https://www.googlecloudcommunity.com/gc/Developer-Tools/GCP-CloudBuild-gt-Failed-to-trigger-build-Couldn-t-read-commit/m-p/509861

Get a Trigger
```
gcloud alpha builds triggers export $(TRIGGERNAME) --region=$REGION --destination=trigger.yaml
```

Get Connections
```
 gcloud alpha builds connections list --region=europe-west2
```

Removing the app completely resulted in:

```shell
ERROR: (gcloud.alpha.builds.triggers.create.github) FAILED_PRECONDITION: connection of repository projects/skillsmapper-management/locations/us-central1/connections/skillsmapper-github-connection/repositories/SkillsMapper cannot be fetched: generic::permission_denied: Permission 'cloudbuild.connections.get' denied on 'projects/262018307079/locations/us-central1/connections/skillsmapper-github-connection'
```


Added to factory-sa

Cloud Build Editor fixes:

```shell
Failed to trigger build: Permission 'cloudbuild.builds.create' denied on resource 'projects/0000003d01821407' (or it may not exist)
```

Default cloud build service account:
https://cloud.google.com/build/docs/cloud-build-service-account


### Cloud Build Service Account 
- 262018307079@cloudbuild.gserviceaccount.com
- Secret Manager Secret Accessor
- Default for Cloud Build

In working project permissions: 104184829272@cloudbuild.gserviceaccount.com
* Cloud Build Service Account
* Cloud Run Admin
* Service Account User

### Cloud Build Service Agent

service-262018307079@gcp-sa-cloudbuild.iam.gserviceaccount.com
- Secret Manager Admin

In addition to the Cloud Build service account, Cloud Build has another Google-managed service account called the Cloud Build Service Agent that allows other Google Cloud services to access your resources.


# Skillsmapper dev
Failed to trigger build: generic::failed_precondition: due to quota restrictions, cannot run builds in this region

## Import Projects

```shell
terraform import google_project.management_project skillsmapper-management
terraform import google_project.dev_project skillsmapper-dev
```
