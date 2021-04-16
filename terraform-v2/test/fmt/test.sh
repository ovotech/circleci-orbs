#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function expect_success() {
    local JOB=$1

    circleci local execute --job $JOB >/tmp/output # | tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" != *"Success"* ]]; then
        echo "Test $JOB Failed"
        exit 1
    fi

    echo "Test $JOB Passed"
}

function expect_fail() {
    local JOB=$1

    circleci local execute --job $JOB >/tmp/output # | tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
        echo "Test $JOB Failed"
        exit 1
    fi

    if ! cat /tmp/output | grep -e "non-canonical/main.tf" >/dev/null; then
        echo "Didn't find a non-canonical file"
        exit 1
    fi

    if ! cat /tmp/output | grep -e "non-canonical/subdir/main.tf" >/dev/null; then
        echo "Didn't find a non-canonical file"
        exit 1
    fi

    echo "Test $JOB Passed"
}

expect_success default_canonical
expect_success terraform_11_canonical
expect_success terraform_12_canonical
expect_fail default_non_canonical
expect_fail terraform_11_non_canonical
expect_fail terraform_12_non_canonical

echo "All tests passed"
