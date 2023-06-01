# Terraform Deployment


## Redeployment

To redeploy with Terraform two resources need to be manually deleted first.

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

Then apply the terraform configuration:

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
