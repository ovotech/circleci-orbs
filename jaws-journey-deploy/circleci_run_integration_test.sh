#!/bin/bash
set -eu
SERVICE_NAME=$1
sudo chmod +x gradlew
#export AWS_REGION=${AWS_DEFAULT_REGION}
./gradlew :${SERVICE_NAME}:integrationTest -Pprofile=${PROFILE} --full-stacktrace