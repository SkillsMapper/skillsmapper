# Terraform Deployment


## Redeployment

To redeploy with Terraform, two resources need to be manually deleted first.

Run:

```shell
set -a; source .env; set +a
```

```shell
gcloud config set project $DEV_PROJECT_ID
```

```shell
gcloud api-gateway gateways delete ${API_NAME}-gateway \
  --location=${REGION} \
  --project=${DEV_PROJECT_ID}
```

```shell
gcloud api-gateway api-configs delete ${API_NAME}-api-gw-config --api ${API_NAME}-api-gw
```

Enable the IAM Service Account Credentials API:

```shell
gcloud services enable iamcredentials.googleapis.com
```


Then apply the Terraform configuration:

```shell
terraform apply
```

Enable Service Usage API:

```shell
gcloud services enable serviceusage.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

```shell
gcloud auth application-default set-quota-project ${DEV_PROJECT_ID}
```

## Generate a service account for Terraform

```shell
set -a; source .env; set +a
```

```shell
gcloud config set project $MANAGEMENT_PROJECT_ID
```

Create a service account in the management project:

```shell
gcloud iam service-accounts create terraform \
  --description="Terraform service account" \
  --display-name="Terraform"
```

Grant the service account the `roles/editor` role in the development project:

```shell
gcloud projects add-iam-policy-binding $DEV_PROJECT_ID \
  --member=serviceAccount:terraform@$MANAGEMENT_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/editor
```
and in the management project:

```shell
gcloud projects add-iam-policy-binding $MANAGEMENT_PROJECT_ID \
  --member=serviceAccount:terraform@$MANAGEMENT_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/editor
```
Then use this service account with Terraform:

```shell
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=terraform@$MANAGEMENT_PROJECT_ID.iam.gserviceaccount.com
```
https://cloud.google.com/blog/topics/developers-practitioners/using-google-cloud-service-account-impersonation-your-terraform-code
