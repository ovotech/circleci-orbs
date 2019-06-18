#!/usr/bin/env bash

include init.sh
terraform workspace select "$workspace" "$module_path"

cat >/tmp/put_plan.py <<"EOF"
include put_plan.py
EOF

set +e

exec 3>&1

terraform plan -input=false -no-color -detailed-exitcode -out=plan.out $PLAN_ARGS "$module_path" \
    | $TFMASK \
    | tee /dev/fd/3 \
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

    if [ -n "$GITHUB_TOKEN" ]; then
        export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
        export TF_ENV_LABEL="<< parameters.label >>"
        python3 /tmp/put_plan.py "$module_path" "$workspace" "$INIT_ARGS" "$PLAN_ARGS" <plan.txt
    fi

fi
