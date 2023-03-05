
Enabled SQL Admin API and secrets API:

```shell
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
```

```shell
gcloud sql instances describe postgres-instance-fb7c22c7
```

```shell
gcloud sql instances describe
```

Download the kubectl credentials for the cluster:

```shell
gcloud container clusters get-credentials p1-tag-updater-manual-gke --region us-central1
``````

```shell
kubectl exec -it workload-identity-test --namespace facts -- /bin/bash
```
```shell
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/email
```
Test token

```shell
curl -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token
```

If connecting using private IP, you must use a VPC-native GKE cluster, in the same VPC as your Cloud SQL instance

## Access Secrets
https://cloud.google.com/kubernetes-engine/docs/tutorials/workload-identity-secrets

## Access SQL
https://cloud.google.com/kubernetes-engine/docs/tutorials/authenticating-to-cloud-sql

```shell
export $(grep -v '^#' .env | xargs)
```

```shell
kubectl create secret generic facts-db-secret \
  --from-literal=username=${DATABASE_USER} \
  --from-literal=password=${DATABASE_PASSWORD} \
  --from-literal=database=${DATABASE_NAME}
```

### Testing with CURL

```shell
kubectl run curlpod --image=curlimages/curl -i --tty -- sh
```

```shell
kubectl exec -i --tty curlpod -- sh
```

### Notes

* Java pod needs 1GB to run reliably
* Java pod takes 30 seconds to start up
* Liveness and readiness delay? https://stackoverflow.com/questions/72467798/k8s-probes-for-spring-boot-services-best-practices
* Does neg check the liveness or just go to /
