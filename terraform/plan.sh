cat >/tmp/github.py <<"EOF"
include github.py
EOF

exec 3>&1

set +e
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
fi

if [[ -n "$GITHUB_TOKEN" && "<< parameters.add_github_comment >>" == "true" ]]; then
    export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
    export label="<< parameters.label >>"

    if ! python3 /tmp/github.py plan <plan.txt; then
        echo "Error adding comment to PR"
    fi
fi
