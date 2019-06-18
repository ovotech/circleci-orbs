#!/usr/bin/env bash

include init.sh
terraform workspace select "$workspace" "$module_path"

terraform destroy -input=false -no-color -auto-approve $PLAN_ARGS "$module_path"
