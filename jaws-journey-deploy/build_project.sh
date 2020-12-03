./gradlew :"<< parameters.serviceName >>":clean :"<< parameters.serviceName >>":buildNeeded -Pprofile=${PROFILE} -x integrationTest --full-stacktrace << parameters.gradleParams >>
