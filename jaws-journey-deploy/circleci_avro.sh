#!/bin/bash
set -eu
sudo chmod +x gradlew
export AWS_REGION=${AWS_DEFAULT_REGION}

if [[ "<< parameters.uploadschema >>" == "true" ]]
then
    ./gradlew avroUploadTask --full-stacktrace
    ./gradlew avroCheckCompatibleTask -PallowNotFound=false --full-stacktrace
else
    ./gradlew avroCheckCompatibleTask -PallowNotFound=true --full-stacktrace
fi