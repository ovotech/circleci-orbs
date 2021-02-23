##
# If the input appears to be a valid base64 string then decode it, otherwise
# return it as is
# Args:
#  * $1 - Potentially base64 encoded string
maybe_decode () {
  local _VAL=${1}

  # Test that the value appears to be a base64 encoded string. If not, return
  # the value immediately
  if ! (grep -E '^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$' <<< "${_VAL}" >/dev/null 2>&1); then
    echo "${_VAL}"
    return 0
  fi

  echo "${_VAL}" | base64 -d
}
