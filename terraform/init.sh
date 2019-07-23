# Initialize terraform
if [[ -n "<< parameters.backend_config_file >>" ]]; then
    for file in $(echo "<< parameters.backend_config_file >>" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$file"
    done
fi

if [[ -n "<< parameters.backend_config >>" ]]; then
    for config in $(echo "<< parameters.backend_config >>" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$config"
    done
fi

export INIT_ARGS

rm -rf .terraform
terraform init -input=false -no-color $INIT_ARGS "$module_path"

# Set workspace from parameter, allowing it to be overridden by TF_WORKSPACE
readonly workspace_parameter="<< parameters.workspace >>"
readonly workspace="${TF_WORKSPACE:-$workspace_parameter}"
export workspace
unset TF_WORKSPACE
