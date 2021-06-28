SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"
SAVE_TOPOLOGY="<< parameters.saveTopology >>"
RUN_INTEGRATION_TEST="<< parameters.runIntegrationTest >>"

if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

if [[ "$SAVE_TOPOLOGY" = true ]] ; then
  if [[ "$RUN_INTEGRATION_TEST" = true ]] ; then
    ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":saveTopologyTask -Pprofile=${PROFILE} --no-daemon --full-stacktrace ${EXCLUDE}
  else
    ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":saveTopologyTask -Pprofile=${PROFILE} --no-daemon --full-stacktrace ${EXCLUDE} -x integrationTest
  fi
else
  if [[ "$RUN_INTEGRATION_TEST" = true ]] ; then
    ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":build -Pprofile=${PROFILE} --no-daemon --full-stacktrace ${EXCLUDE}
  else
    ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":build -Pprofile=${PROFILE} --no-daemon --full-stacktrace ${EXCLUDE} -x integrationTest
  fi
fi
