#!/bin/bash
set -eu
SERVICE_NAME=$1
PROFILE=$2
sudo chmod +x gradlew
./gradlew :${SERVICE_NAME}:clean :${SERVICE_NAME}:buildNeeded -Pprofile=${PROFILE} -x integrationTest --full-stacktrace