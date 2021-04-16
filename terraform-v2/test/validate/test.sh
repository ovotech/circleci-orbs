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
    local ERROR=$2

    circleci local execute --job $JOB >/tmp/output # | tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
        echo "Test $JOB Failed"
        exit 1
    fi

    if ! cat /tmp/output | grep -e "$ERROR" >/dev/null; then
        echo "Validate didn't have expected error"
        exit 1
    fi

    echo "Test $JOB Passed"
}

expect_success default_valid
expect_success terraform_11_valid
expect_success terraform_12_valid
expect_fail default_invalid "null_resource.hello: resource repeated multiple times"
expect_fail terraform_11_invalid "null_resource.hello: resource repeated multiple times"
expect_fail terraform_12_invalid "Error: Duplicate resource \"null_resource\" configuration"

echo "All tests passed"
