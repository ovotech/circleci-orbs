#!/bin/bash
set -eu
CD_PUBLISH=$1
sudo chmod +x gradlew
export AWS_REGION=${AWS_DEFAULT_REGION}

if [[ ${CD_PUBLISH} == "true" ]]
then
    ./gradlew avroUploadTask --full-stacktrace
    ./gradlew avroCheckCompatibleTask -PallowNotFound=false --full-stacktrace
else
    ./gradlew avroCheckCompatibleTask -PallowNotFound=true --full-stacktrace
fi