
RETRIES="<< parameters.retries >>"
RETRY_DELAY="<< parameters.retry_delay >>"

for ((i=0; i <= $RETRIES)); do
  TF_EXIT=terraform destroy -input=false -no-color -auto-approve $PLAN_ARGS "$module_path"

  if [[ $TF_EXIT -eq 0 ]]; then
    break
  fi

  if [[ $i -nq $RETRIES ]]; then
    sleep $RETRY_DELAY
  fi
done

exit $TF_EXIT