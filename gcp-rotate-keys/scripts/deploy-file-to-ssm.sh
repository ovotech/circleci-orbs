##
# Deploy a key to AWS SSM parameter store
# Args:
#  * $1 - Path to deploy to
#  * $2 - File containing the key
deploy_file_to_ssm() {
  local _PATH="$1"
  local _FILE="$2"

  echo "Deploying to AWS SSM parameter store at ${_PATH}"
  AWS_PAGER="" aws ssm put-parameter --name="${_PATH}" --type="SecureString" --value="file://${_FILE}" --overwrite
}
