function countdown() {
    seconds=$1
    while [ $seconds -gt 0 ]; do
        sleep 1
        echo -ne "."
        : $((seconds--))
    done
    echo ""
}

RETRIES="<< parameters.retries >>"
RETRY_DELAY="<< parameters.retry_delay >>"

for ((i=0; i <= $RETRIES; i++)); do
  echo "Destroy (Attempt: $(expr $i + 1)"
  set +e
  terraform destroy -input=false -no-color -auto-approve $PLAN_ARGS "$module_path"
  TF_EXIT=$?
  set -e

  if [[ $TF_EXIT -eq 0 ]]; then
    break
  fi

  if [[ $i -ne $RETRIES ]]; then
    echo -ne "Delay ${RETRY_DELAY}s before next attempt"
    countdown $RETRY_DELAY
  fi
done

if [[ $TF_EXIT -ne 0 ]]; then
  exit 1
fi
