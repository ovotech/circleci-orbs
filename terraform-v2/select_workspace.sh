set -x

terraform -chdir=${module_path} workspace select -no-color "${workspace}"
