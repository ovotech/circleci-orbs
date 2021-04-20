set -x

if terraform -chdir=${module_path} workspace list -no-color | grep "$workspace" >/dev/null; then
  terraform -chdir=${module_path} workspace select -no-color "$workspace"
else
  terraform -chdir=${module_path} workspace new -no-color -lock-timeout=300s "$workspace"
fi

