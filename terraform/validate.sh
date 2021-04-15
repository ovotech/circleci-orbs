chdir=""
config_path="${module_path}"
# -chdir was introduced in terraform 0.14 and is necessary in 0.14 to make sure the
# provider lock file in the terraform config directory is picked up. However, older
# versions of terraform need the terraform config directory to be specified at the
# end of the command
if terraform -help | grep -e "-chdir" >/dev/null && "<< parameters.use_chdir >>" == "true"; then
  chdir="-chdir=${module_path}"
  config_path=
fi

rm -rf .terraform
terraform $chdir init -input=false -backend=false -no-color $config_path

if terraform $chdir validate -help | grep -e "-check-variables" > /dev/null; then
    terraform $chdir validate -no-color -check-variables=false $config_path
else
    terraform $chdir validate -no-color $config_path
fi
