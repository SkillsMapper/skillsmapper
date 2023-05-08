
set -a; source ../.env; source .env; set +a
export DOLLAR='$' envsubst
export RELEASE_TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
envsubst < ../factory/templates/cloudbuild.yaml.template > cloudbuild.yaml
envsubst < ../factory/templates/clouddeploy.yaml.template > clouddeploy.yaml
envsubst < ../factory/templates/skaffold.yaml.template > skaffold.yaml
envsubst < ../factory/templates/deploy-dev.yaml.template > deploy-dev.yaml
envsubst < ../factory/templates/deploy-qa.yaml.template > deploy-qa.yaml
envsubst < ../factory/templates/deploy-prod.yaml.template > deploy-prod.yaml
