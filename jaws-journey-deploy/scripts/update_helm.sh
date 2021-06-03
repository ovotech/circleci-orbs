MAX_RETRY=3
COUNTER=0

function deploy_manifest {

  # Ensure /tmp/gitops is empty
  cd ~/
  rm -rf /tmp/gitops
  mkdir -p /tmp/gitops
  
  # Clone manifest repo
  git clone git@github.com:${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} /tmp/gitops
  cd /tmp/gitops
  
  # Update helm chart
  yq e ".jaws-journey-helm-chart.buildTag=\"${CIRCLE_SHA1}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml
  yq e ".jaws-journey-helm-chart.releaseVersion=\"${CIRCLE_TAG:-$CIRCLE_BRANCH-${CIRCLE_SHA1:0:8}}\"" -i <<parameters.manifest_directory>>/values-<<parameters.environment>>.yaml
  
  # Commit manifest changes
  git config user.name '<<parameters.git_name>>'
  git config user.email '<<parameters.git_email>>'
  git commit -m "[skip ci] <<parameters.environment>>: CircleCI deploy ${CIRCLE_PROJECT_REPONAME}" -m  "Deployment to <<parameters.environment>>. Build URL: ${CIRCLE_BUILD_URL}" -a

  if '${CIRCLE_BRANCH}' === '<<parameters.deploy_branch>>'
    git tag -d sandbox
    git tag sandbox
    git push origin :sandbox
    git push origin sandbox
    git push origin '<<parameters.deploy_branch>>'
  fi

  return $?
}


until deploy_manifest
do
   sleep 1
   [[ COUNTER -eq $MAX_RETRY ]] && echo "Failed!" && exit 1
   echo "Trying again. Try #$COUNTER"
   ((COUNTER++))
done