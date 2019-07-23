#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function expect_fail() {
    local JOB="$1"
    local HOST="$2"
    local TOKEN="$3"
    local ERROR="$4"

    echo "Running $JOB"

    set -o pipefail
    circleci local execute --env TF_REGISTRY_HOST=$HOST --env TF_REGISTRY_TOKEN=$TOKEN --job $JOB >/tmp/job_output #| tee /tmp/job_output

    if ! grep "^$ERROR" < /tmp/job_output >/dev/null; then
        echo "Didn't find error message $ERROR in output"
        exit 2
    fi

    if ! grep "^Error: runner failed" < /tmp/job_output >/dev/null; then
        echo "Job didn't fail"
        exit 2
    fi

    echo "Test Passed"
}

function expect_pass() {
    local JOB="$1"
    local HOST="$2"
    local TOKEN="$3"
    local MESSAGE="$4"

    echo "Running $JOB"

    circleci local execute --env TF_REGISTRY_HOST=$HOST --env TF_REGISTRY_TOKEN=$TOKEN --job $JOB >/tmp/job_output #| tee /tmp/job_output

    if ! grep "^$MESSAGE" < /tmp/job_output >/dev/null; then
        echo "Didn't find message $MESSAGE in output"
        exit 2
    fi

    echo "Test Passed"
}

expect_fail empty_path_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "module_path parameter must be set"
expect_fail wrong_path_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "module_path \"doesnt exist\" doesn't exist"
expect_fail empty_name_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "module_name parameter must be set"
expect_fail wrong_name_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "curl: (22) The requested URL returned error: 403"
expect_fail empty_version_file_path_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "version_file_path parameter must be set"
expect_fail wrong_version_file_path_param "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "Version file \"doesnt exist\" doesn't exist"
expect_fail invalid_version "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "Not a valid version: \"not a version\""

expect_fail publish "$TF_REGISTRY_HOST" "" "TF_REGISTRY_TOKEN environment variable must be set"
expect_fail publish "" "$TF_REGISTRY_TOKEN" "TF_REGISTRY_HOST environment variable must be set"
expect_fail publish "$TF_REGISTRY_HOST" "wrongtoken" "curl: (22) The requested URL returned error: 401"

expect_pass publish "$TF_REGISTRY_HOST" "$TF_REGISTRY_TOKEN" "Published $TF_REGISTRY_HOST/required_creds_pe/publish-module-test/aws@0.0.1"

echo "All tests passed"
