##
# Validates the service account
# Args:
#  * $1 - Email of the service account to validate
validate_service_account() {
  local _SA="$1"

  if [[ "${_SA}" == "" ]]; then
    echo "Service account parameter is missing"
    exit 1
  fi

  if ! (gcloud iam service-accounts list --filter "email=${_SA}" | grep "${_SA}" >/dev/null 2>&1); then
    echo "Could not find service account ${_SA}"
    exit 1
  fi

  _KC=$(gcloud iam service-accounts keys list --filter='keyType=USER_MANAGED' --format='json' --iam-account "${_SA}" | jq '. | length')
  if [[ "${_KC}" -ne "1" ]]; then
    echo "Service account has ${_KC} keys. Unable to rotate"
    exit 1
  fi
}
