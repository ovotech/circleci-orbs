terraform workspace select -no-color "default" "$module_path"
terraform workspace delete -no-color "$workspace" "$module_path"
