yq e ".buildTag=\"${CIRCLE_SHA1}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml
yq e ".releaseVersion=\"${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml

git clone git@github.com:${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} /tmp/gitops
cd /tmp/gitops
git config user.name '<<parameters.git_name>>'
git config user.email '<<parameters.git_email>>'
git commit -m "[skip ci] CircleCI deploy with helm ${CIRCLE_PROJECT_REPONAME}" -m  "Build URL: ${CIRCLE_BUILD_URL}" -a
git push origin << parameters.deploy_branch >>