sudo chmod +x gradlew
export AWS_REGION=${AWS_DEFAULT_REGION}

if [[ "<< parameters.uploadschema >>" == "true" ]]
then
    ./gradlew avroUploadTask --full-stacktrace
    ./gradlew avroCheckCompatibleTask  -Pprofile=${PROFILE} -PallowNotFound=false --full-stacktrace
else
    ./gradlew avroCheckCompatibleTask  -Pprofile=${PROFILE} -PallowNotFound=true --full-stacktrace
fi