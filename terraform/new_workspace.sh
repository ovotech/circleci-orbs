if terraform "$chdir" workspace list -no-color $config_path | grep "$workspace" >/dev/null; then
  terraform "$chdir" workspace select -no-color "$workspace" $config_path
else
  terraform "$chdir" workspace new -no-color -lock-timeout=300s "$workspace" $config_path
fi
