set -x

if [[ "<< parameters.parallelism >>" -ne 0 ]]; then
    PLAN_ARGS="$PLAN_ARGS -parallelism=<< parameters.parallelism >>"
fi

if [[ -n "<< parameters.var >>" ]]; then
    for var in $(echo "<< parameters.var >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var $var"
    done
fi

if [[ -n "<< parameters.target >>" ]]; then
    for target in $(echo "<< parameters.target >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -target $target"
    done
fi

if [[ -n "<< parameters.var_file >>" ]]; then
    for file in $(echo "<< parameters.var_file >>" | tr ',' '\n'); do
        # TODO Testing: make sure that this works for files specified
        # from the top level and for files specified relative to the
        # terraform configuration
        if [[ -f "$file" ]]; then
            # chdir needs files to be specified relative to the terraform
            # config file, so change this to be a relative path
            rel_path=$(realpath --relative-to ${module_path} ${file})
            PLAN_ARGS="$PLAN_ARGS -var-file=$rel_path"
        elif [[ -f "$module_path/$file" ]]; then
            PLAN_ARGS="$PLAN_ARGS -var-file=$file"
        else
            echo "Var file '$file' wasn't found" >&2
            exit 1
        fi
    done
fi

export PLAN_ARGS
