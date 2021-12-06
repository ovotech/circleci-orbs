export AWS_REGION=${AWS_DEFAULT_REGION}
export SERVICE_NAME=$1
./gradlew :${SERVICE_NAME}:test -Pprofile=${PROFILE} --full-stacktrace -PrunEndToEndTests=true
