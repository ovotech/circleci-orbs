
RETRIES="<< parameters.retries >>"
RETRY_DELAY="<< parameters.retry_delay >>"

for ((i=0; i <= $RETRIES; i++)); do
  terraform destroy -input=false -no-color -auto-approve $PLAN_ARGS "$module_path"
  TF_EXIT=$?

  if [[ $TF_EXIT -eq 0 ]]; then
    break
  fi

  if [[ $i -ne $RETRIES ]]; then
    sleep $RETRY_DELAY
  fi
done

exit $TF_EXIT