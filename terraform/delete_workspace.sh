terraform workspace select -no-color "default" "$module_path"
terraform workspace delete -no-color -lock-timeout=300s "$workspace" "$module_path"
