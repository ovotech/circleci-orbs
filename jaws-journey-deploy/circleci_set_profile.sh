#!/bin/bash
set -eu
ENVIRONMENT=$1

echo ${PROFILE}
echo 'export PROFILE='${ENVIRONMENT}'' >> $BASH_ENV
echo "export VERSION=${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}" >> $BASH_ENV