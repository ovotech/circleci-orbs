##
# If the input appears to be a valid base64 string then decode it, otherwise
# return it as is
# Args:
#  * $1 - Potentially base64 encoded env var
maybe_decode () {
  local _VAR=${1}
  local _VAL=""

  _VAL="$(printenv "${_VAR}")"

  # Test that the value appears to be a base64 encoded string. If not, return
  if ! (grep -E '^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$' <<< "${_VAL}" >/dev/null 2>&1); then
    return 0
  fi

  echo "export ${_VAR}='$(echo "${_VAL}" | base64 -d)'" >> "${BASH_ENV}"
}
