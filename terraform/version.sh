rm -rf .terraform
terraform init -input=false -backend=false -no-color "$module_path"
terraform version -input=false -no-color
