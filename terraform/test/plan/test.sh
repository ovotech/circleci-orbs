#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function expect_success() {
    local JOB=$1
    local MESSAGE=$2

    circleci local execute --job $JOB >/tmp/output #| tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" != *"Success"* ]]; then
        echo "Test $JOB Failed"
        exit 1
    fi

    if ! cat /tmp/output | grep -e "$MESSAGE" >/dev/null; then
        echo "Output didn't have expected message"
        exit 1
    fi

    echo "Test $JOB Passed"
}

function expect_fail() {
    local JOB=$1
    local ERROR=$2

    circleci local execute --job $JOB >/tmp/output #| tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
        echo "Test $JOB Failed"
        exit 1
    fi

    if ! cat /tmp/output | grep -e "$ERROR" > /dev/null; then
        echo "Output didn't have expected error"
        exit 1
    fi

    echo "Test $JOB Passed"
}

expect_success default_plan "Terraform will perform the following"
expect_success default_no_changes "No changes."
expect_fail default_error "Error running terraform"
expect_success terraform_11_plan "Terraform will perform the following"
expect_success terraform_11_no_changes "No changes."
expect_fail terraform_11_error "Error running terraform"
expect_success terraform_12_plan "Terraform will perform the following"
expect_success terraform_12_no_changes "No changes."
expect_fail terraform_12_error "Error running terraform"

expect_fail default_no_path "Path does not exist"
expect_fail default_no_workspace "Workspace \"none\" doesn't exist."

echo "All tests passed"
