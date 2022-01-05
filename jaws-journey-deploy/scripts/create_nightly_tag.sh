#!/bin/bash
set -e
GITHUB_BOT_TOKEN="<< parameters.token >>"

if [[ -z "$GITHUB_BOT_TOKEN" ]] ; then
   echo "GITHUB_BOT_TOKEN was not set at input (second argument)"
   exit 1
fi

URL_BASE="https://api.github.com/repos/ovotech/${CIRCLE_PROJECT_REPONAME}"
AUTH_HEADER="Authorization: Bearer $GITHUB_BOT_TOKEN"
TAG_NAME="nightly"
echo "TAG_NAME $TAG_NAME"

COMMIT_RESPONSE=$(curl --silent --show-error --fail --request GET "${URL_BASE}/commits/master" --header "$AUTH_HEADER") || exit
COMMIT_SHA=$(echo "$COMMIT_RESPONSE" | jq -r '.sha')
echo "Latest commit on master: $COMMIT_SHA"

TAG_REQUEST="{\"tag\": \"$TAG_NAME\", \"object\": \"$COMMIT_SHA\", \"type\":\"commit\", \"message\":\"Nightly automation test\"}"
TAG_RESPONSE=$(curl -sSf --request POST "${URL_BASE}/git/tags" --header "$AUTH_HEADER" --header 'Content-Type: application/json' --data "$TAG_REQUEST") || exit
TAG_SHA=$(echo "$TAG_RESPONSE" | jq -r '.sha')

REF_REQUEST="{\"ref\": \"refs/tags/$TAG_NAME\", \"sha\": \"$TAG_SHA\"}"
curl --fail --request POST "${URL_BASE}/git/refs" --header "$AUTH_HEADER" --header 'Content-Type: application/json' --data "$REF_REQUEST"