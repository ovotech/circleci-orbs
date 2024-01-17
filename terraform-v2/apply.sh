set -x

cat >/tmp/github.py <<"EOF"
include github.py

EOF

cat >/tmp/comment_util.py <<"EOF"
include comment_util.py

EOF

export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
export label="<< parameters.label >>"

function update_status() {
    local status="$1"

    if ! echo "$status" | python3 /tmp/github.py status; then
        echo "Unable to update status on PR"
    fi
}

function apply() {
    set +e
    terraform -chdir=${module_path} apply -input=false -no-color -auto-approve -lock-timeout=300s plan.out | $TFMASK
    local TF_EXIT=${PIPESTATUS[0]}
    set -e

    if [[ $TF_EXIT -eq 0 ]]; then
        update_status "Plan applied in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
    else
        update_status "Error applying plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
        exit 1
    fi
}

if [[ "<< parameters.auto_approve >>" == "true" && -n "<< parameters.target >>" ]]; then
    for target in $(echo "<< parameters.target >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -target $target"
    done
fi

if [[ "<< parameters.auto_approve >>" == "true" && -n "<< parameters.replace >>" ]]; then
    for target in $(echo "<< parameters.replace >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -replace $target"
    done
fi

update_status "Applying plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"

exec 3>&1

set +e


if [[ "<< parameters.reuse_plan >>" == "false" ]]; then
    if [[ "<< parameters.trim_plan >>" == "true" ]]; then
      terraform -chdir=${module_path} plan -input=false -no-color -detailed-exitcode -lock-timeout=300s -out=plan.out $PLAN_ARGS
      TF_EXIT=$?
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
      
          TF_EXIT=${PIPESTATUS[0]}
    fi 

    
    if [[ $TF_EXIT -eq 1 ]]; then
        update_status "Error creating plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
        exit 1
    fi
fi


set -e

function sanitise_plan() {
  local plan="$1"
  echo "$plan" | sed -E '/Releasing state lock. This may take a few moments\.\.\./d' | awk '{gsub(/^[[:space:]]*~ latest_restorable_time[[:space:]]*=.*$/,"")};1'
}


if [[ "<< parameters.auto_approve >>" == "true" || $TF_EXIT -eq 0 ]]; then
    echo "Automatically approving plan"
    apply

else
    if ! python3 /tmp/github.py get >approved-plan.txt; then
        echo "Approved plan not found"
        exit 1
    fi

    set +x
        
    plan=$(cat "plan.txt")
    approved_plan=$(cat "approved-plan.txt")

    sanitised_plan=$(sanitise_plan "$plan")
    sanitised_approved_plan=$(sanitise_plan "$approved_plan")

    sanitised_plan_file=$(mktemp)
    sanitised_approved_plan_file=$(mktemp)
    echo "$sanitised_plan" > "$sanitised_plan_file"
    echo "$sanitised_approved_plan" > "$sanitised_approved_plan_file"

    # run diff on temporary files
    if diff_output=$(diff "$sanitised_plan_file" "$sanitised_approved_plan_file"); then
        apply
    else
        update_status "Plan not applied in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL}) (Plan has changed)"
        echo "$diff_output"
        exit 1
    fi
fi
