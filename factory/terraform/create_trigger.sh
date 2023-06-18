#!/bin/bash

# Define function to create _KEY=VALUE format for each variable
function format_var() {
    echo "_$(echo $1 | tr '[:lower:]' '[:upper:]')=$(echo $2)"
}

# Read tfvars file and build substitution string
substitutions=""
while IFS='= ' read -r key value
do
    if [[ ! -z "$key" && ! -z "$value" && "$key" != \#* ]]; then
        formatted_var=$(format_var $key $value)
        substitutions="$substitutions,$formatted_var"
    fi
done < terraform.tfvars
substitutions=${substitutions:1}

# Create the trigger
gcloud beta builds triggers create github \
  --name=$TRIGGER_NAME \
  --repository=projects/$PROJECT_ID/locations/$REGION/connections/$CONNECTION_NAME/repositories/$REPO_NAME \
  --branch-pattern=$BRANCH_PATTERN \
  --build-config=$BUILD_CONFIG_FILE \
  --region=$REGION \
  --substitutions=$substitutions
