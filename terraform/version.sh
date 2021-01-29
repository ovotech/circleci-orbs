rm -rf .terraform
terraform "$chdir" init -input=false -backend=false -no-color "$config_path"
terraform version -input=false -no-color
