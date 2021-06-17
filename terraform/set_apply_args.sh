if [[ "<< parameters.parallelism >>" -ne 0 ]]; then
    APPLY_ARGS="$APPLY_ARGS -parallelism=<< parameters.parallelism >>"
fi

export APPLY_ARGS