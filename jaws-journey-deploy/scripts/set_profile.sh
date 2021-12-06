export AUTOMATED_TEST_SUITE = "<< parameters.automatedTestSuite >>"
export PROFILE="<< parameters.environment >>"
export VERSION=${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}
