if [[ "<< parameters.parallelism >>" -ne 0 ]]; then
    PLAN_ARGS="$PLAN_ARGS -parallelism=<< parameters.parallelism >>"
fi

if [[ -n "<< parameters.var >>" ]]; then
    for var in $(echo "<< parameters.var >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var $var"
    done
fi

if [[ -n "<< parameters.var_file >>" ]]; then
    for file in $(echo "<< parameters.var_file >>" | tr ',' '\n'); do
        if [[ -f "$file" ]]; then
            PLAN_ARGS="$PLAN_ARGS -var-file=$file"
        elif [[ -f "$module_path/$file" ]]; then
            PLAN_ARGS="$PLAN_ARGS -var-file=$module_path/$file"
        else
            echo "Var file '$file' wasn't found" >&2
            exit 1
        fi
    done
fi

export PLAN_ARGS
