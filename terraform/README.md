# Terraform Deployment

## Initial Deployment

If you haven't already, create a management project and a development project.

## Import the two projects

```shell
terraform import google_project.management_project $MANAGEMENT_PROJECT_ID
terraform import google_project.dev_project $DEV_PROJECT_ID
```

```shell
set -a; source .env; set +a
```

```shell
gcloud config set project $MANAGEMENT_PROJECT_ID
```

Create a name for the Terraform bucket:

```shell
export BUCKET_NAME=${MANAGEMENT_PROJECT_ID}-tfstate
```

Then use `gsutil` to create the bucket:

```shell
gsutil mb -p $MANAGEMENT_PROJECT_ID -c regional -l $REGION gs://$BUCKET_NAME
```

Update the Terraform `main.tf` file with the bucket name e.g.:

```hcl
  backend "gcs" {
  bucket = "skillsmapper-management-2-tfstate"
  prefix = "terraform/state"
}
```

Initialize Terraform:

```shell
terraform init
```

Then apply the Terraform configuration:

```shell
terraform apply
```

## Redeployment

To redeploy with Terraform, two resources need to be manually deleted first.

Set local environment variables:

```shell
set -a; source .env; set +a
```

Set the current project to development:

```shell
gcloud config set project $DEV_PROJECT_ID
```

Delete the API Gateway:

```shell
gcloud api-gateway gateways delete ${API_NAME}-gateway \
  --location=${REGION} \
  --project=${DEV_PROJECT_ID}
```

Delete the API Gateway Config:

```shell
gcloud api-gateway api-configs delete ${API_NAME}-api-gw-config --api ${API_NAME}-api-gw
```

If Cloud Build has run delete the services as it will be a newer version than the Terraform configuration:

```shell
gcloud run services delete skill-service --region ${REGION}
gcloud run services delete fact-service --region ${REGION}
gcloud run services delete profile-service --region ${REGION}
```

Then apply the Terraform configuration:

```shell
terraform apply
```

## Other

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

## Terraform Trigger

```shell
set -a; source ../.env; source .env; source .env.trigger; set +a
```

```shell
gcloud config set project $MANAGEMENT_PROJECT_ID
```

Remove existing trigger:

```shell
gcloud beta builds triggers delete $TRIGGER_NAME --region=$REGION
```

Create new trigger:

```shell
./create_terraform_trigger.sh
```

## Troubleshooting

List Cloud Run:

```shell
gcloud run services list --region=$REGION
```

Remember to create images for the current commit before deploying.
