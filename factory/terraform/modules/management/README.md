```shell
set -a; source .env; set +a
```

https://cloud.google.com/build/docs/automating-builds/github/build-repos-from-github?generation=2nd-gen#gcloud_1

```shell
gcloud alpha builds triggers create github \
  --name=TRIGGER_NAME \
  --repository=projects/$PROJECT_ID/locations/$REGION/connections/$CONNECTION_NAME/repositories/$REPO_NAME \
  --branch-pattern="^main$" \
  --build-config=BUILD_CONFIG_FILE \
  --region=$REGION
```
