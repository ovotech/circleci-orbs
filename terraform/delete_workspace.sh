terraform $chdir workspace select -no-color "default" $config_path
terraform $chdir workspace delete -no-color -lock-timeout=300s "$workspace" $config_path
