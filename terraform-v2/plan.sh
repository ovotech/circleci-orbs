set -x

cat >/tmp/github.py <<"EOF"
include github.py
EOF
echo "" >> /tmp/github.py

cat >/tmp/comment_util.py <<"EOF"
include comment_util.py
EOF
echo "" >> /tmp/comment_util.py

exec 3>&1

set +e
terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300s -out=plan.out $PLAN_ARGS \
    | $TFMASK \
    | tee /dev/fd/3 \
    | $COMPACT_PLAN \
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
