export TF_VAR_release_version=${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}
export TF_VAR_build_tag=${CIRCLE_SHA1}
