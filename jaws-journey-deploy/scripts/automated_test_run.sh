export AWS_REGION=${AWS_DEFAULT_REGION}
./gradlew :${AUTOMATED_TEST_SUITE}:test -Pprofile=${PROFILE} --full-stacktrace -PrunEndToEndTests=true
