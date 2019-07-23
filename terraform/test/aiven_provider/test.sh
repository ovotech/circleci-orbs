#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

function test_case() {
    local JOB=$1
    local VERSION=$2

    circleci local execute --job $JOB >/tmp/output #| tee /tmp/output

    if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
        echo "Job $JOB Success"
    else
        echo "Job $JOB Fail"
        exit 1
    fi

    if ! grep "$VERSION" /tmp/output > /dev/null; then
        echo "Failed test $JOB"
        exit 2
    fi
}

test_case terraform_11_aiven "provider.aiven v1.0.10"
test_case terraform_11 "provider.aiven v0.0.1"
test_case terraform_12 "provider.aiven v1.0.10"

echo "All tests passed"
