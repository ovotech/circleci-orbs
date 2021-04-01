git config user.name '<<parameters.git_name>>'
git config user.email '<<parameters.git_email>>'
git commit -m "[skip ci] CircleCI deploy with helm ${CIRCLE_PROJECT_REPONAME}" -m  "Build URL: ${CIRCLE_BUILD_URL}" -a
git push
