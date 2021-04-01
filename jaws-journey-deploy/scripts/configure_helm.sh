yq e ".buildTag=\"${CIRCLE_SHA1}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml
yq e ".releaseVersion=\"${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml
