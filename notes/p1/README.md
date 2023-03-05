# Tag Updater

In this chapter we start by using two Google Cloud commandline tools `bq` for big query and `gsutil` for cloud storage. We will use these to query the StackOverflow dataset and write the results to a file in Cloud Storage.

This is how we can do it on the command line.

Collect tags from Big Query

* bq limits the maximum number of rows to 100 by default. We use --max_rows=0 to remove this limit. 
* we use `--nouse_legacy_sql` to ...
* we use `--format=prettyjson` to output as json

```shell
bq query --max_rows=1000 --nouse_legacy_sql --format=prettyjson "SELECT id, tag_name FROM bigquery-public-data.stackoverflow.tags order by tag_name" > tags.json
```

Write the file to Cloud Storage:

We define environment variables to separate out configuration from the commands:
````shell
export BUCKET_NAME=skillsmapper-tags
export FILE_NAME=tags.json
export OBJECT_NAME=tags.json
export REGION=europe-west2
``
````

Create a bucket:

```shell
gsutil mb gs://$BUCKET_NAME
```

Copy the file to the Cloud Storage bucket:

```shell
gsutil cp $FILE_NAME gs://$BUCKET_NAME/$OBJECT_NAME
```

However, we can automate this further using a programing language, in this case   Go in `main.go`.

We will keep configuration in environment variables in a `.env` file. We use the `godotenv` package to load the environment variables from the file.

We can test the function locally using main_test.go using the `go test` command:

```shell
godotenv -f ./.env go test . -cover
```

### Deploy

Cloud Functions generation 2 are effectively a convience wrapper around Cloud Run and Cloud Build which we will use in the next chapter. Cloud Run is a managed container platform that allows you 
to run containers that are invocable via HTTP requests. Cloud Build is a managed build service that allows you to build container images. Cloud Functions however abstract both away building using 
a standard container.

We are loading the results of the BigQuery into memory so that will need a bit more memory than the default 256MB. We can set this using the `--memory` flag to set it to 512MB.

To deploy the cloud function we use the `gcloud` commandline tool:

```shell
gcloud functions deploy tagupdater \
--gen2 \
--runtime=go119 \
--region=$REGION \
--source=. \
--trigger-http \
--env-vars-file=.env.yaml
```

We can check it has been created using:

```shell
gcloud functions list
```

and run the function using:

```shell
gcloud functions call tagupdater --region=$REGION
```

## Creating a Service Account

By default Cloud Functions run as the `service-ACCOUNT_ID@PROJECT_ID.iam.gserviceaccount.com` service account. However this will have broad permissions. We want to ensure that the cloud function 
only has the permissions it needs, in this case to access query BigQuery and write to Cloud Storage.

We need to create a service account to allow the cloud function to access the BigQuery and Cloud Storage APIs.

```shell
export PROJECT_ID=$(gcloud config get-value project)
export SERVICE_ACCOUNT=tagupdater-sa
```

```shell
gcloud iam service-accounts create $SERVICE_ACCOUNT \
  --description="Service account for tagupdater" \
  --display-name="tagupdater"
```

We need to give the service account permission to run a query in BigQuery and retrieve the results. We can do this using the `gcloud` commandline tool:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/bigquery.jobUser
```

We then need to give the service account permission to create object in Cloud Storage. We can do this using the `gcloud` commandline tool:

```shell
gcloud projects add-iam-policy-binding $PROJECT_ID \
   --member=serviceAccount:$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.objectCreator
```

```shell
gcloud iam service-accounts describe tagupdater-sa@fresh-delight-357607.iam.gserviceaccount.com
```

### Cloud Scheduler

Enable the Cloud Scheduler API:

```shell
gcloud services enable cloudscheduler.googleapis.com
```

Set the region otherwise we will need to specify the region on every command. (only works with app engine)
    
```shell
gcloud config set run/region $REGION
```

Schedule:

Schedule to run at midnight every Sunday and trigger the HTTP endpoint of the Cloud Function.

By default Cloud Scheduler will retry a job 3 times if it fails. We can change this using the `--max-retry-attempts` flag.

```shell
gcloud scheduler jobs create http tagupdater \
  --schedule="0 0 * * SUN" \
  --uri=https://tagupdater-apaqw6pdaa-nw.a.run.app \
  --max-retry-attempts=3 \
  --location=$REGION
```

Check the status of the job:

```shell
gcloud scheduler jobs list --location=$REGION
```

Trigger manually regardless of schedule:

```shell
gcloud scheduler jobs run tagupdater --location=$REGION
```

Check the status of the job:

```shell
gcloud scheduler jobs describe tagupdater --location=$REGION
```

Check the log of the Cloud Function:

```shell    
gcloud functions logs read --gen2 --region=$REGION
```

Check the data of the file in cloud storage:

```shell
gsutil ls -l gs://$BUCKET_NAME/$OBJECT_NAME
```

## Terraform Version



## Emulators

* [Cloud Storage Emulator](https://cloud.google.com/go/docs/reference/cloud.google.com/go/storage/latest)

## References

* [BigQuery](https://cloud.google.com/go/docs/reference/cloud.google.com/go/bigquery/latest)
* [Cloud Storage](https://cloud.google.com/go/docs/reference/cloud.google.com/go/storage/latest)
& [https://towardsdatascience.com/how-to-schedule-a-serverless-google-cloud-function-to-run-periodically-249acf3a652e]

https://cloud.google.com/functions/docs/concepts/go-runtime

[CLI Tips](https://www.youtube.com/watch?v=ezzZ--xt43c&ab_channel=GoogleCloudTech)
