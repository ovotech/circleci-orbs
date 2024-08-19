set -x

cat >/tmp/github.py <<"EOF"
include github.py

EOF

cat >/tmp/comment_util.py <<"EOF"
include comment_util.py

EOF

exec 3>&1

set +e

if [[ "<< parameters.trim_plan >>" == "true" ]]; then
  terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300s -out=plan.out $PLAN_ARGS
  readonly TF_EXIT=$?
  (cd ${module_path};
  terraform show -no-color plan.out \
      | $TFMASK \
      | $COMPACT_PLAN \
   ) > plan.txt
else
  terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300s -out=plan.out $PLAN_ARGS \
          | $TFMASK \
          | tee /dev/fd/3 \
          | $COMPACT_PLAN \
              >plan.txt

  readonly TF_EXIT=${PIPESTATUS[0]}
fi

set -e

if [[ $TF_EXIT -eq 1 ]]; then
    echo "Error running terraform"
    exit 1
fi

if [[ -n "$GITHUB_TOKEN" && "<< parameters.add_github_comment >>" == "true" ]]; then
    export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
    export label="<< parameters.label >>"

    if terraform show -no-color plan.out | grep 'No changes' >/dev/null 2>&1; then
      if [[ "<< parameters.add_no_changes_comment >>" == "true" ]]; then
        if ! python3 /tmp/github.py plan <plan.txt; then
            echo "Error adding comment to PR"
        fi
      fi
    else
      if ! python3 /tmp/github.py plan <plan.txt; then
          echo "Error adding comment to PR"
      fi
    fi
fi
