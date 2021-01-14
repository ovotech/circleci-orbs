export AWS_REGION=${AWS_DEFAULT_REGION}
export SERVICE_NAME=automated-test
./gradlew :${SERVICE_NAME}:test -Pprofile=${PROFILE} --full-stacktrace -PrunEndToEndTests=true
