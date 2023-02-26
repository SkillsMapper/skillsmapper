# Setup

This is a summary of [Chapter S1](../chapters/chs1.asciidoc)

## Prerequisites

Install the Google Cloud CLI using the [instructions](https://cloud.google.com/sdk/docs/install).

Update the gcloud cli:

```shell
gcloud components update
```

Authenticate with Google Cloud:

```shell
gcloud auth login
```

## Create a Project

Create an environment variable to store the `PROJECT_ID`:

```shell
export PROJECT_ID=[PROJECT_ID]
```

Alternatively set `PROJECT_ID` in `.env` file and then apply it using:

```shell
export $(grep -v '^#' .env | xargs)
```

Create the new project:

```shell
gcloud projects create $PROJECT_ID
```

Set the new project as default:

```shell
gcloud config set project $PROJECT_ID
```

## Enable Billing

Find the `ACCOUNT_ID` of the open billing account you would like to use:

```shell
gcloud beta billing accounts list
```

Add the `ACCOUNT_ID` to a `BILLING_ACCOUNT_ID` environment variable:

```shell
export BILLING_ACCOUNT_ID=[ACCOUNT_ID]
```

Link the Billing Account to the Project:

```shell
gcloud beta billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT_ID
```
