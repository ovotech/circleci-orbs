#!/usr/bin/env bash

set -e

mkdir -p .circleci

sed -e "s|ovotech/terraform@1|ovotech/terraform@dev:${USER}_test|" config.yml | circleci config process - >.circleci/config.yml

export GITHUB_USERNAME=danielflookovo
export GITHUB_TOKEN=$GITHUB_TOKEN
export CIRCLE_PROJECT_USERNAME=ovotech
export CIRCLE_PROJECT_REPONAME=pe-terraform-orb-test
export CIRCLE_PR_NUMBER=1

python3 delete_comments.py

circleci local execute --job terraform_11_plan \
      --branch test1 \
      --repo-url https://github.com/ovotech/pe-terraform-orb-test \
      --revision 30288e0af0256ef370b6d28eb406dce642e183a6 \
      --skip-checkout  \
      --env GITHUB_USERNAME=$GITHUB_USERNAME \
      --env GITHUB_TOKEN=$GITHUB_TOKEN \
      --env CIRCLE_PROJECT_USERNAME=$CIRCLE_PROJECT_USERNAME \
      --env CIRCLE_PROJECT_REPONAME=$CIRCLE_PROJECT_REPONAME \
      --env CIRCLE_PR_NUMBER=$CIRCLE_PR_NUMBER \
    | tee /tmp/output

if [[ "$(tail -n 1 /tmp/output)" == *"Success"* ]]; then
    echo "Job $JOB Success"
else
    echo "Job $JOB Fail"
    exit 1
fi

echo "All tests passed"
