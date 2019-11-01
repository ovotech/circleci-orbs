cat >/tmp/github.py <<"EOF"
include github.py
EOF

cat >/tmp/cmp.py <<"EOF"
include cmp.py
EOF

export CIRCLE_PR_NUMBER="${CIRCLE_PR_NUMBER:-${CIRCLE_PULL_REQUEST##*/}}"
export label="<< parameters.label >>"

function update_status() {
    local status="$1"

    if ! echo "$status" | python3 /tmp/github.py status; then
        echo "Unable to update status on PR"
    fi
}

function plan() {
    exec 3>&1

    set +e
    terraform plan -input=false -no-color -detailed-exitcode -out=plan.out $PLAN_ARGS "$module_path" \
        | $TFMASK \
        | tee /dev/fd/3 \
        | sed '1,/---/d' \
            >plan.txt

    TF_EXIT=${PIPESTATUS[0]}
    set -e

    if [[ $TF_EXIT -eq 1 ]]; then
        update_status "Error applying plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
        return 1
    fi

    return 0
}

function apply() {        
    set +e
    terraform apply -input=false -no-color -auto-approve plan.out | $TFMASK
    local TF_EXIT=${PIPESTATUS[0]}
    set -e

    if [[ $TF_EXIT -eq 0 ]]; then
        update_status "Plan applied in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
        return 0
    else
        update_status "Error applying plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"
        return 1
    fi
}

if [[ "<< parameters.auto_approve >>" == "true" && -n "<< parameters.target >>" ]]; then
    for target in $(echo "<< parameters.target >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -target $target"
    done
fi

update_status "Applying plan in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL})"

if [[ "<< parameters.auto_approve >>" == "true" || $TF_EXIT -eq 0 ]]; then
    echo "Automatically approving plan"

    RETRIES="<< parameters.retries >>"
    RETRY_DELAY="<< parameters.retry_delay >>"

    for ((i=0; i <= $RETRIES; i++)); do
        if plan && apply; then 
            break
        fi

        if [[ $i -nq $RETRIES ]]; then
            sleep $RETRY_DELAY
        fi
    done

else
    if ! plan; then
        exit 1
    fi

    if ! python3 /tmp/github.py get >approved-plan.txt; then
        echo "Approved plan not found"
        exit 1
    fi

    if python3 /tmp/cmp.py plan.txt approved-plan.txt; then
        exit apply
    else
        update_status "Plan not applied in CircleCI Job [${CIRCLE_JOB}](${CIRCLE_BUILD_URL}) (Plan has changed)"
        exit 1
    fi
fi
