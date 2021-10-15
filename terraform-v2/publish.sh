#!/usr/bin/env bash

set -e
set -o pipefail

readonly MODULE_PATH="<< parameters.path >>"
readonly MODULE_NAME="<< parameters.module_name >>"
readonly VERSION_FILE_PATH="<< parameters.version_file_path >>"

if [[ "$MODULE_PATH" == "" ]]; then
    echo "module_path parameter must be set"
    exit 2
fi

if [[ ! -d "$MODULE_PATH" ]]; then
    echo "module_path \"$MODULE_PATH\" doesn't exist"
    exit 2
fi

if [[ "$MODULE_NAME" == "" ]]; then
    echo "module_name parameter must be set"
    exit 2
fi

if [[ "$VERSION_FILE_PATH" == "" ]]; then
    echo "version_file_path parameter must be set"
    exit 2
fi

if [[ ! -f "$VERSION_FILE_PATH" ]]; then
    echo "Version file \"$VERSION_FILE_PATH\" doesn't exist"
    exit 2
fi

readonly VERSION=$(<"$VERSION_FILE_PATH")

if [[ ! "$VERSION" =~ [[:digit:]]+\.[[:digit:]]+\.[[:digit:]] ]]; then
    echo "Not a valid version: \"$VERSION\""
    exit 2
fi

if [[ "$TF_REGISTRY_HOST" == "" ]]; then
    echo "TF_REGISTRY_HOST environment variable must be set"
    exit 2
fi

if [[ "$TF_REGISTRY_TOKEN" == "" ]]; then
    echo "TF_REGISTRY_TOKEN environment variable must be set"
    exit 2
fi

cd "$MODULE_PATH"
tar -czvf "/tmp/$VERSION.tar.gz" *

REGISTRY_URL=$(curl --fail -sL "https://$TF_REGISTRY_HOST/.well-known/terraform.json" | jq -r '."modules.v1"')

if [[ "$REGISTRY_URL" == "" ]]; then
    echo "Failed to find registry API"
    exit 2
fi

EXISTING_VERSION=$(curl "${REGISTRY_URL}${MODULE_NAME}/versions" | jq -c '.modules[0].versions[] | select(.version == '\"$VERSION\"')')

if [[ ! -z "$EXISTING_VERSION" ]]; then
    echo "Version $VERSION already exists"
    exit 2
fi

readonly PRESIGNED_URL="$(curl -Ls -o /dev/null --fail -X PUT "$REGISTRY_URL$MODULE_NAME/$VERSION/upload" \
  -H "Authorization: Bearer $TF_REGISTRY_TOKEN" \
  -H "Content-Length: 0" \
  -w %{url_effective}
)"

if [[ "$PRESIGNED_URL" == "" ]]; then
  echo "Failed to get presigned URL"
  exit 2
fi

curl -L --fail -X PUT "$PRESIGNED_URL" \
  --data-binary "@/tmp/$VERSION.tar.gz" \
  -H "Content-Type: application/x-tar"

echo "Published $TF_REGISTRY_HOST/$MODULE_NAME@$VERSION"
