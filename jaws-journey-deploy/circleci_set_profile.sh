#!/bin/bash
set -eu
echo ${PROFILE}
echo 'export PROFILE="<< parameters.environment >>"' >> $BASH_ENV
echo "export VERSION=${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}" >> $BASH_ENV