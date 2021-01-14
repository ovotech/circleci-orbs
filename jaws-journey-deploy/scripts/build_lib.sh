CONTAINS_INTEGRATION_TESTS="<< parameters.contains_integration_tests >>"
if [[ "CONTAINS_INTEGRATION_TESTS" = true ]] ; then
  ./gradlew :libs:"<< parameters.lib >>":clean :libs:"<< parameters.lib >>":"<< parameters.command >>"  -Pprofile=${PROFILE} -x integrationTest --full-stacktrace
else
  ./gradlew :libs:"<< parameters.lib >>":clean :libs:"<< parameters.lib >>":"<< parameters.command >>" --full-stacktrace
fi