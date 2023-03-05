# Fact Service

## What you will learn

In this lab you will learn methods for developing with containers in GCP including:
[*] Creating a new Java starter application
[*] Creating a simple CRUD Rest Service
[*] Enable Jib etc.
[*] Configuring the app for container development

[*] Deploying to Minikube
[ ] Utilizing breakpoint / logs
[ ] Hot deploying changes back to Minikube

## Pre-requisites

### Minikube with Podman on M1 Mac

Install Podman and Minikube.

```shell
brew install podman
brew install minikube
```

Create a Podman virtual machines
```shell
podman machine init --cpus 2 --memory 2048 --rootful
podman machine start
```

Start a new Minikube cluster using the Podman virtual machine.
```shell
minikube start --driver=podman
```

### Set Environment Variables

```shell
export $(grep -v '^#' .env | xargs)
```

### Set Project

```shell
gcloud config set project $PROJECT_ID
```

## Create a GKE Autopilot Cluster

Enable the GKE Autopilot API:

```shell
gcloud services enable container.googleapis.com 
```

Create an autopilot cluster:

```shell
gcloud beta container clusters create-auto skillsmapper --region $REGION --project $PROJECT_ID
```


Install the GKE auth plugin:

```shell
gcloud components install gke-gcloud-auth-plugin
```

Check no pods are running:

```shell
kubectl get pods
```

Build and deploy using Skaffold:

```shell
skaffold run
```

```shell
kubectl get pods
```

```shell
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
```

* https://www.thecloudpeople.com/blog/gke-autopilot-helps-you-save-costs-and-improve-time-to-market
* https://wdenniss.com/autopilot-pending-pods

GKE Classic had higher limits than autopilot clusters.

Seems to take a long time for deployments to stablise.




Generate manifests for Skaffold
```shell
skaffold init --generate-manifests --XXenableJibInit
```
When prompted:
* Use the arrows to move your cursor to **<code>Jib Maven Plugin</code></strong>
* Press the spacebar to select the option.
* Press enter to continue 
* Enter *8080* for the port
*Enter *y* to save the configuration

This will generate two files: `skaffold.yaml` and `deployment.yaml`.

## Update app name

The default values included in the configuration don’t currently match the name of your application. Update the files to reference your application name rather than the default values.

1. Change entries in Skaffold config
    * Open `skaffold.yaml`
    * Select the image name currently set as `pom-xml-image`
    * Right click and choose Change All Occurrences
    * Type in the new name as `fact-service`
2. Change entries in Kubernetes config
    * Open `deployment.yaml` file
    * Select the image name currently set as` pom-xml-image`
    * Right click and choose Change All Occurrences
    * Type in the new name as `fact-service`


gcloud services enable containerregistry.googleapis.com

https://skaffold.dev/docs/pipeline-stages/builders/jib/

go install github.com/GoogleCloudPlatform/docker-credential-gcr@latest

gcloud auth configure-docker

export IMAGE=fact-service

mvn compile com.google.cloud.tools:jib-maven-plugin:2.8.0:build \
-Dimage=gcr.io/$PROJECT_ID/$IMAGE

settings.xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
<servers>
<server>
<id>registry-1.docker.io</id>
<username>YOUR_DOCKER_HUB_USERNAME</username>
<password>YOUR_DOCKER_HUB_PASSWORD</password>
</server>
</servers>
</settings>
```




## Prerequisites

### Setup a project

Set an environment variable to the new project name:
```shell
export PROJECT_ID=<project_id>
```

Login to gcloud CLI if you are not already:
```shell
gcloud auth login
```

Create a new project:
```shell
gcloud projects create $PROJECT_ID
```

and set switch to the new project
```shell
gcloud config set project $PROJECT_ID
```

Save the project number to an environment variable:
```shell
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
```

Find the `ACCOUNT_ID` for a billing account to use for the project:
```shell
gcloud beta billing accounts list
```

and add it to an environment variable:
```shell
export BILLING_ACCOUNT_ID=<ACCOUNT_ID>
```

Enable billing for the project:
```shell
gcloud beta billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID
```

Enable artifact repository
```shell
gcloud services enable artifactregistry.googleapis.com
```
Pick a location to use
```shell
gcloud config set artifacts/location europe-central2
```
Define an artifact repo name
```shell
export ARTIFACT_REPO_NAME=fact-repo
```
Create a new docker repo
```shell
gcloud artifacts repositories create $ARTIFACT_REPO_NAME --repository-format=docker
````

---
Set the default repo for skaffold to use
```shell
skaffold config set default-repo $ARTIFACT_REPO_NAME 
```

## Ingress

https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#container-native_load_balancing
