SKIP_UNIT_TESTS="<< parameters.skipUnitTests >>"

if [[ "$SKIP_UNIT_TESTS" = true ]] ; then
  EXCLUDE="-x test"
else
  EXCLUDE=""
fi

./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":buildNeeded -Pprofile=${PROFILE} -x integrationTest --full-stacktrace ${EXCLUDE}
