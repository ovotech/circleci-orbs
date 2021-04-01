##
# Configures the environment with environment [nonprod/prod] specific values
# Args:
#  * $1 - Environment [nonprod/prod/etc]
#  * $2 - Comma or Space delimited list of env vars to configure
configure_environment() {
  local ENV=${1}
  local VAR_LIST=${2}

  IFS=', ' read -r -a VARS <<<"${VAR_LIST}"
  for VAR in "${VARS[@]}"; do
    if [[ -z "$(printenv ${ENV^^}_${VAR})" ]]; then
      echo "Missing environment variable ${ENV^^}_${VAR}"
      exit 1
    fi
    echo "export ${VAR}='"$(printenv ${ENV^^}_${VAR})"'" >> "${BASH_ENV}"
  done
}
