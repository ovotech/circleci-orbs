SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"
SAVE_TOPOLOGY="<< parameters.saveTopology >>"
RUN_INTEGRATION_TEST="<< parameters.runIntegrationTest >>"
SERVICE="<< parameters.serviceName >>"

if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

if [[ "RUN_INTEGRATION_TEST" = true ]] ; then
  INTEGRATION_TEST=":$SERVICE:integrationTest"
else
  INTEGRATION_TEST="-x integrationTest"
fi

if [[ "$SAVE_TOPOLOGY" = true ]] ; then
  ./gradlew :"<< parameters.serviceName >>":clean :"$SERVICE":saveTopologyTask -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}" "${INTEGRATION_TEST}"
else
  ./gradlew :"<< parameters.serviceName >>":clean :"$SERVICE":build -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}" "${INTEGRATION_TEST}"
fi
