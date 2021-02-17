SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"
SAVE_TOPOLOGY="<< parameters.skipUnitTests >>"
if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

if [[ "SAVE_TOPOLOGY" = true ]] ; then
  ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":saveTopologyTask -Pprofile=${PROFILE} -x integrationTest --full-stacktrace ${EXCLUDE}
else
  ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":buildNeeded -Pprofile=${PROFILE} -x integrationTest --full-stacktrace ${EXCLUDE}
fi
