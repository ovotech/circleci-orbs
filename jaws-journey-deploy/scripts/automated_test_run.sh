export AWS_REGION=${AWS_DEFAULT_REGION}
./gradlew :${SERVICE_NAME}:test -Pprofile=${PROFILE} --full-stacktrace -PrunEndToEndTests=true
