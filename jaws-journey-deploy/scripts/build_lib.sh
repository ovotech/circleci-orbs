CONTAINS_INTEGRATION_TESTS="<< parameters.contains_integration_tests >>"
COMMAND="<< parameters.command >>"
if [[ "CONTAINS_INTEGRATION_TESTS" = true ]] ; then
  ./gradlew :libs:"<< parameters.lib >>":clean :libs:"<< parameters.lib >>":$COMMAND -Pprofile=${PROFILE} -x integrationTest --full-stacktrace
else
  ./gradlew :libs:"<< parameters.lib >>":clean :libs:"<< parameters.lib >>":$COMMAND --full-stacktrace
fi