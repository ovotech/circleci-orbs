##
# Deletes an existing key for a given service account
# Args:
#  * $1 - Service Account email address
#  * $2 - ID of the key to delete
delete_key() {
  local _SA="$1"
  local _KEY="$2"

  echo "Deleting key ID ${_KEY}"
  gcloud iam service-accounts keys delete "${_KEY}" --iam-account "${_SA}" --quiet
}
