if terraform workspace list -no-color "$module_path" | grep "$workspace" >/dev/null; then
  terraform workspace select -no-color "$workspace" "$module_path"
else
  terraform workspace new -no-color "$workspace" "$module_path"
fi
