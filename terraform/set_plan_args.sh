if [[ "<< parameters.parallelism >>" -ne 0 ]]; then
    PLAN_ARGS="$PLAN_ARGS -parallelism=<< parameters.parallelism >>"
fi

# Implement the subtly broken auto loading behaviour
if [[ -f "$module_path/terraform.tfvars" ]]; then
    PLAN_ARGS="$PLAN_ARGS -var-file $module_path/terraform.tfvars"
fi

if [[ -f "$module_path/terraform.tfvars.json" ]]; then
    PLAN_ARGS="$PLAN_ARGS -var-file $module_path/terraform.tfvars.json"
fi

for file in "$module_path"/*.auto.tfvars; do
    PLAN_ARGS="$PLAN_ARGS -var-file $file"
done

for file in "$module_path"/*.auto.tfvars.json; do
    PLAN_ARGS="$PLAN_ARGS -var-file $file"
done

if [[ -n "<< parameters.var >>" ]]; then
    for var in $(echo "<< parameters.var >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var $var"
    done
fi

if [[ -n "<< parameters.var_file >>" ]]; then
    for file in $(echo "<< parameters.var_file >>" | tr ',' '\n'); do
        PLAN_ARGS="$PLAN_ARGS -var-file=$file"
    done
fi

export PLAN_ARGS
