#!/usr/bin/env bash

include init.sh
terraform workspace select "$workspace" "$module_path"

set +e

terraform plan -input=false -no-color -detailed-exitcode $PLAN_ARGS "$module_path" \
    | $TFMASK \
    | sed '1,/---/d' \
        >plan.txt

readonly TF_EXIT=${PIPESTATUS[0]}

set -e

if [[ $TF_EXIT -eq 1 ]]; then
    echo "Error running terraform"
    exit 1

elif [[ $TF_EXIT -eq 0 ]]; then
    echo "No changes to apply"

elif [[ $TF_EXIT -eq 2 ]]; then

    echo "Changes detected!"
    cat plan.txt

    exit 1

fi
