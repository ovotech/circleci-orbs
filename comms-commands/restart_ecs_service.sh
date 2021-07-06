#!/usr/bin/env bash

set -eo pipefail

aws ecs update-service \
  --force-new-deployment \
  --cluster "${ECS_CLUSTER}" \
  --service "${ECS_SERVICE}" \
  --query "service.deployments[?status=='PRIMARY'][]" \

while :
do
  deploy_status=$(
    aws ecs describe-services \
      --cluster "${ECS_CLUSTER}" \
      --services "${ECS_SERVICE}" \
      --query "services[0].deployments[?status=='PRIMARY'].rolloutState" \
      --output text
  )
  if [ $deploy_status == "COMPLETED" ]
  then
    echo "=== Deployment successful ==="
    exit 0
  else if [ $deploy_status == "FAILED" ]
    echo "=== Deployment FAILED ==="
    exit 1
  else
    echo "Deployment status: ${deploy_status}. Waiting..."
    sleep 2
  fi
done
