rm -rf .terraform
terraform init -input=false -backend=false -no-color "$module_path"

if terraform validate -help | grep -e "-check-variables" > /dev/null; then
    terraform validate -no-color -check-variables=false "$module_path"
else
    terraform validate -no-color "$module_path"
fi
