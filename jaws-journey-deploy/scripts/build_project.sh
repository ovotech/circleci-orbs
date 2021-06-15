SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"
SAVE_TOPOLOGY="<< parameters.saveTopology >>"
RUN_INTEGRATION_TEST="<< parameters.runIntegrationTest >>"
SERVICE="<< parameters.serviceName >>"

if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

if [[ "$SAVE_TOPOLOGY" = true ]] ; then
  if [[ "$RUN_INTEGRATION_TEST" = true ]] ; then
    ./gradlew :"$SERVICE":clean :"$SERVICE":saveTopologyTask :"$SERVICE":integrationTest -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}"
  else
    ./gradlew :"$SERVICE":clean :"$SERVICE":saveTopologyTask -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}" -x integrationTest
  fi
else
  if [[ "$RUN_INTEGRATION_TEST" = true ]] ; then
    ./gradlew :"$SERVICE":clean :"$SERVICE":build :"$SERVICE":integrationTest -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}"
  else
    ./gradlew :"$SERVICE":clean :"$SERVICE":build -Pprofile="${PROFILE}" --no-daemon --full-stacktrace "${EXCLUDE}" -x integrationTest
  fi
fi
