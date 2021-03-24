SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"
SAVE_TOPOLOGY="<< parameters.saveTopology >>"

if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

if [[ "$SAVE_TOPOLOGY" = true ]] ; then
  ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":saveTopologyTask -Pprofile=${PROFILE} --no-daemon -x integrationTest --full-stacktrace ${EXCLUDE}
else
  ./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":build :"<< parameters.serviceName >>":shadow -Pprofile=${PROFILE} --no-daemon -x integrationTest --full-stacktrace ${EXCLUDE}
fi
