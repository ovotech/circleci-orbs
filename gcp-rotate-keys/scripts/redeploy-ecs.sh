##
# Redeploys a service on ECS to pick up new keys
# Args:
#  * $1 - Cluster name
#  * $2 - Service name
#  * $3 - Number of seconds to wait for update until aborting
redeploy_ecs() {
  local _CLUSTER="$1"
  local _SERVICE="$2"
  local _TIMEOUT="$3"

  echo "Redeploying ${_SERVICE} on cluster ${_CLUSTER}"
  AWS_PAGER="" aws ecs update-service --cluster "${_CLUSTER}" --service "${_SERVICE}" --force-new-deployment

  ##
  # Wait to reach a steady state
  local _START=""
  local _UPDATED="0"
  _START="$(date +%s)"

  while [[ "${_UPDATED}" -lt "1" ]]; do
    if [[ "$(date +%s)" -gt $((_START + _TIMEOUT)) ]]; then
      echo "Timed out while waiting for ${_SERVICE} to reach steady state"
      return 1
    fi

    sleep 5

    _UPDATED=$(
      AWS_PAGER="" aws ecs describe-services --cluster "${_CLUSTER}" --service "${_SERVICE}" \
        | TZ=UTC jq --arg now "${_START}" --arg name "${_SERVICE}" \
          '.services[]
          | select(.serviceName == $name).events
          | map(select(
            (.createdAt
              | sub("(?<time>T[0-9:]+)(\\.\\d+)?(?<tz>Z|[+\\-]\\d{2}:?(\\d{2})?)$"; .time + .tz)
              | sub("Z$"; "+00:00")
              | sub("(?<h>[+\\-]\\d{2}):?(?<m>\\d{2})$"; .h + .m)
              | strptime("%Y-%m-%dT%H:%M:%S%z")
              | mktime >= ($now | tonumber))
            and
            (.message | contains("reached a steady state"))
          ))
          | length'
    )
  done
}
