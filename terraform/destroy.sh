terraform destroy -input=false -no-color -auto-approve -lock-timeout=300s $PLAN_ARGS "$module_path"
