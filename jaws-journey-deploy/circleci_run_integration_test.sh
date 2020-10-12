#!/bin/bash
set -eu
sudo chmod +x gradlew
#export AWS_REGION=${AWS_DEFAULT_REGION}
./gradlew :"<< parameters.serviceName >>":integrationTest -Pprofile=${PROFILE} --full-stacktrace