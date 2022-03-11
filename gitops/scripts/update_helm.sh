MAX_RETRY=3
COUNTER=0
VALUES_FILE="<<parameters.values_file>>"

if [ -z "$VALUES_FILE" ]
then
      VALUES_FILE="manifests/values-<<parameters.environment>>-<< parameters.region >>.yaml"
fi

ssh-keyscan github.com >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts

function deply_manifest {

  # Ensure /tmp/gitops is empty
  cd ~/
  rm -rf /tmp/gitops
  mkdir -p /tmp/gitops
  
  # Clone manifest repo
  git clone -b <<parameters.manifest_branch>> git@github.com:${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME} /tmp/gitops
  cd /tmp/gitops
  
  # Update helm chart
  yq e "<<parameters.image_tag_yaml_path>>=\"<<parameters.image_tag>>\"" -i $VALUES_FILE
  
  # Commit manifest changes
  git config user.name '<<parameters.git_name>>'
  git config user.email '<<parameters.git_email>>'
  git commit -m "[skip ci] <<parameters.environment>> <<parameters.region>>: CircleCI deploy ${CIRCLE_PROJECT_REPONAME}" -m  "Deployment to <<parameters.environment>> / <<parameters.region>>. Build URL: ${CIRCLE_BUILD_URL}" -a

  if [[ "<< parameters.commit_tag_name >>" != "" ]]; then
    git push origin :refs/tags/<< parameters.commit_tag_name >>
    git tag -f '<< parameters.commit_tag_name >>' -a -m "$CIRCLE_BUILD_URL"
  fi

  git push origin << parameters.manifest_branch >> --tags

  return $?
}

until deply_manifest
do
   sleep 1
   [[ COUNTER -eq $MAX_RETRY ]] && echo "Failed!" && exit 1
   echo "Trying again. Try #$COUNTER"
   ((COUNTER++))
done

cd /tmp/gitops
mkdir -p /tmp/argocd
touch /tmp/argocd/env
echo "export ARGOCD_TARGET_REVISION=$(git rev-parse origin/<< parameters.manifest_branch >>)" >> /tmp/argocd/env
