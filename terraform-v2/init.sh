set -x

# Initialize terraform
if [[ -n "<< parameters.backend_config_file >>" ]]; then
    for file in $(echo "<< parameters.backend_config_file >>" | tr ',' '\n'); do
        if [[ -f "$file" ]]; then
            # chdir needs files to be specified relative to the terraform 
            # config file, so change this to be a relative path
            rel_path=$(realpath --relative-to ${module_path} ${file})
            INIT_ARGS="$INIT_ARGS -backend-config=${rel_path}"
        elif [[ -f "$module_path/$file" ]]; then
            INIT_ARGS="$INIT_ARGS -backend-config=$file"
        else
            echo "Backend config '$file' wasn't found" >&2
            exit 1
        fi
    done
fi

if [[ -n "<< parameters.backend_config >>" ]]; then
    for config in $(echo "<< parameters.backend_config >>" | tr ',' '\n'); do
        INIT_ARGS="$INIT_ARGS -backend-config=$config"
    done
fi

export INIT_ARGS

# Set workspace from parameter, allowing it to be overridden by TF_WORKSPACE.
# If TF_WORKSPACE is set we don't want terraform init to use the value, in the case we are running new_workspace.sh this would cause an error
# REMOVE ME: Publish dev orb
readonly workspace_parameter="<< parameters.workspace >>"
readonly workspace="${TF_WORKSPACE:-$workspace_parameter}"
export workspace
unset TF_WORKSPACE

rm -rf ${module_path}/.terraform
terraform -chdir=${module_path} init -input=false -no-color $INIT_ARGS
