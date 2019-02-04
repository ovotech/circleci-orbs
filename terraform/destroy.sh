#!/usr/bin/env bash

set -e

GCLOUD_SERVICE_KEY="${GCLOUD_SERVICE_KEY:-$GOOGLE_SERVICE_ACCOUNT}"

if [ -n "$GCLOUD_SERVICE_KEY" ]; then
    echo "$GCLOUD_SERVICE_KEY" \
        | base64 --decode --ignore-garbage \
            >/tmp/google_creds

    export GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_creds
    gcloud auth activate-service-account --key-file /tmp/google_creds
fi

if [ -n "$GOOGLE_PROJECT_ID" ]; then
    gcloud --quiet config set project "$GOOGLE_PROJECT_ID"
fi

if [ -n "$GOOGLE_COMPUTE_ZONE" ]; then
    gcloud --quiet config set compute/zone "$GOOGLE_COMPUTE_ZONE"
fi

readonly module_path="<< parameters.path >>"
if [[ -z "$TF_WORKSPACE" ]]; then
    readonly workspace="$TF_WORKSPACE"
    echo "Using overriden workspace environment variable: $workspace "
else
    readonly workspace="<< parameters.workspace >>"
fi

if [ -n "<< parameters.parallelism >>" ]; then
    PLAN_ARGS="$PLAN_ARGS -parallelism=<< parameters.parallelism >>"
fi

if [ -n "<< parameters.backend_config_file >>" ]; then
    for file in $(echo "<< parameters.backend_config_file >>" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$file"
    done
fi

if [ -n "<< parameters.backend_config >>" ]; then
    for config in $(echo "<< parameters.backend_config >>" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$config"
    done
fi

if [ -n "<< parameters.var >>" ]; then
    for var in $(echo "<< parameters.var >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var $var"
    done
fi

if [ -n "<< parameters.var_file >>" ]; then
    for file in $(echo "<< parameters.var_file >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var-file=$file"
    done
fi

rm -rf .terraform
terraform init -input=false -no-color $INIT_ARGS "$module_path"
terraform workspace select "$workspace" "$module_path"

exec terraform destroy -input=false -no-color -auto-approve $PLAN_ARGS "$module_path"
