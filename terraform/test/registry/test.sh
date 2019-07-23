#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function test_case() {
    local JOB=$1
    local MESSAGE=$2
    local TOKEN="$3"

    echo "Running $JOB"

    if ! circleci local execute --env TF_REGISTRY_HOST=terraform.ovotech.org.uk --env TF_REGISTRY_TOKEN=$TOKEN --job $JOB | tee /dev/stderr | grep "^$MESSAGE" >/dev/null; then
        echo "Failed test $JOB"
        exit 2
    fi
}

test_case no_creds_no_module "Terraform has been successfully initialized!" ""
test_case required_creds_module "Terraform has been successfully initialized!" $TF_REGISTRY_TOKEN
test_case guest_module "Terraform has been successfully initialized!" ""

test_case wrong_creds_module "Error downloading modules: Error loading modules: error looking up module versions: 401 Unauthorized" "hello :)"

echo "All tests passed"
