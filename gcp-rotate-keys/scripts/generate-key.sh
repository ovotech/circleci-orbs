##
# Generates a key for a given service account. Saves the path where the key
# is generated to the GENERATED_KEY_PATH environment variable in the $BASH_ENV
# file. Also saves the generated key ID to the GENERATED_KEY_ID environment
# variable in the $BASH_ENV file
# Args:
#  * $1 - Service Account email address
generate_key() {
  local _SA="$1"
  local GENERATED_KEY_PATH=""
  local GENERATED_KEY_ID=""

  echo "Generating key"
  GENERATED_KEY_PATH="$(mktemp).json"
  GENERATED_KEY_ID=$(
    gcloud iam service-accounts keys create "${GENERATED_KEY_PATH}" \
      --iam-account "${_SA}" 2>&1 | grep -Eo '([0-9a-f]{40})'
  )

  echo "export GENERATED_KEY_ID=${GENERATED_KEY_ID}" >> "${BASH_ENV}"
  echo "export GENERATED_KEY_PATH=${GENERATED_KEY_PATH}" >> "${BASH_ENV}"
}
