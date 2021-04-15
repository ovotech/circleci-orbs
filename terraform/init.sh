export chdir=""
export config_path="${module_path}"
# -chdir was introduced in terraform 0.14 and is necessary in 0.14 to make sure the
# provider lock file in the terraform config directory is picked up. However, older
# versions of terraform need the terraform config directory to be specified at the
# end of the command
if terraform -help | grep -e "-chdir" >/dev/null && "<< parameters.use_chdir >>" == "true"; then
  chdir="-chdir=${module_path}"
  config_path=
fi

# Initialize terraform
if [[ -n "<< parameters.backend_config_file >>" ]]; then
    for file in $(echo "<< parameters.backend_config_file >>" | tr ',' '\n'); do
        if [[ -f "$file" ]]; then
            INIT_ARGS="$INIT_ARGS -backend-config=$file"
        elif [[ -f "$module_path/$file" ]]; then
            INIT_ARGS="$INIT_ARGS -backend-config=$module_path/$file"
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
readonly workspace_parameter="<< parameters.workspace >>"
readonly workspace="${TF_WORKSPACE:-$workspace_parameter}"
export workspace
unset TF_WORKSPACE

rm -rf .terraform
terraform $chdir init -input=false -lock-timeout=300s -no-color $INIT_ARGS $config_path
