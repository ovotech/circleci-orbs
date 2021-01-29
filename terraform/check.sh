exec 3>&1

set +e
terraform "$chdir" plan -input=false -no-color -detailed-exitcode -lock-timeout=300s $PLAN_ARGS "$config_path"  \
    | $TFMASK \
    | tee /dev/fd/3 \
    | $COMPACT_PLAN \
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
    exit 1

fi
