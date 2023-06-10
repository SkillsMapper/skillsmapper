[source,shell]
-----
USER_EMAIL=$(gcloud config get-value account)
gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:$USER_EMAIL --role=roles/cloudbuild.connectionAdmin
-----

[source,shell]
-----
PN=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
CLOUD_BUILD_SERVICE_AGENT="service-${PN}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
--member="serviceAccount:${CLOUD_BUILD_SERVICE_AGENT}" \
--role="roles/secretmanager.admin"
-----
