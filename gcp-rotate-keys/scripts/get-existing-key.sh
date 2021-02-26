##
# Gets the existing key(s) for a given service account and saves the ID of the
# key into the PREVIOUS_KEY_ID environment variable in the $BASH_ENV file
# Args:
#  * $1 - Service Account email address
get_existing_key() {
  local _SA="$1"
  local PREVIOUS_KEY_ID=""

  PREVIOUS_KEY_ID=$(
    gcloud iam service-accounts keys list \
      --filter='keyType=USER_MANAGED' \
      --format='value(name)' \
      --iam-account "${_SA}"
  )

  echo "export PREVIOUS_KEY_ID=${PREVIOUS_KEY_ID}" >> "${BASH_ENV}"
}
