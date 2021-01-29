rm -rf .terraform
terraform "$chdir" init -input=false -backend=false -no-color "$config_path"

if terraform "$chdir" validate -help | grep -e "-check-variables" > /dev/null; then
    terraform "$chdir" validate -no-color -check-variables=false "$config_path"
else
    terraform "$chdir" validate -no-color "$config_path"
fi
