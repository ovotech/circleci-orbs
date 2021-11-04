set -x

terraform -chdir=${module_path} destroy -input=false -no-color -auto-approve -lock-timeout=300s $PLAN_ARGS
