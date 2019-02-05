#!/usr/bin/env bash

include init.sh
terraform workspace select "$workspace" "$module_path"

cat >/tmp/get_plan.py <<"EOF"
include get_plan.py
EOF

cat >/tmp/cmp.py <<"EOF"
include cmp.py
EOF

set +e

terraform plan -input=false -no-color -detailed-exitcode -out=plan.out $PLAN_ARGS "$module_path" \
    | sed '1,/---/d' \
        >plan.txt

readonly TF_EXIT=${PIPESTATUS[0]}

set -e

if [[ $TF_EXIT -eq 1 ]]; then
    echo "Error running terraform"
    exit 1

elif [[ $TF_EXIT -eq 0 ]]; then
    # No changes to apply
    echo "No changes to apply"

elif [[ $TF_EXIT -eq 2 ]]; then

    if [ "<< parameters.auto_approve >>" = "true" ]; then
        echo "Automatically approving plan"
        exec terraform apply -input=false -no-color -auto-approve plan.out
    fi

    export TF_ENV_LABEL="<< parameters.label >>"

    if ! python3 /tmp/get_plan.py "$module_path" "$workspace" "$INIT_ARGS" "$PLAN_ARGS" >approved-plan.txt; then
        echo "Approved plan not found"
        exit 1
    fi

    if python3 /tmp/cmp.py plan.txt approved-plan.txt; then
        echo "Applying approved plan"
        exec terraform apply -input=false -no-color -auto-approve plan.out
    else
        echo "Plan has changed - approval needed"
        cat plan.txt
        exit 1
    fi

fi
