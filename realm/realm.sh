#!/bin/sh

# try and get the realm API key from the proper env var, failover to the legacy
# shipit equivalent if it's not present
realm_api_key=
if [ -n "$REALM_API_KEY" ]; then
    realm_api_key="${REALM_API_KEY}"
else
    if [ -n "$SHIPIT_API_KEY" ]; then
        realm_api_key="${SHIPIT_API_KEY}"
    fi
fi

if [ -z "${realm_api_key}" ]; then
    echo "The REALM_API_KEY env var needs to be set. Head over to #kaluza-sre-public if you need one generated"
fi

env="<< parameters.environment >>"
realm_env="prod"
# if env = prod then hit Prod Realm, otherwise hit UAT Realm
if [ "${env}" != "prod" ]; then
    realm_env="uat"
fi
realm_url="https://realm.eu1.${realm_env}.kaluza.com/realm"

# if realm status hasn't been passed in as "started" or "unknown", then grab the status
# from a local file which the orb has populated with either "success" or "failure"
realm_status="<< parameters.status >>"
if [ "<< parameters.auto-status >>" = "true" ]; then
	realm_status=$(cat /tmp/REALM_STATUS)
fi

curl \
  "${realm_url}" \
  --header "Content-Type: application/json" \
  --header "X-API-Key: ${realm_api_key}" \
  --data-binary @- << EOF
{
    "build": "${CIRCLE_BUILD_NUM}",
    "cicd_provider": "circleci",
    "env": "${env}",
    "git_hash": "${CIRCLE_SHA1}",
    "kaluza_region": "<< parameters.kaluza-region >>",
    "notify_slack_channel": "<< parameters.notify-slack-channel >>",
    "retailer": "<< parameters.retailer >>",
    "service": "${CIRCLE_PROJECT_REPONAME}",
    "status": "${realm_status}",
    "team": "<< parameters.team-name >>"
}
EOF
