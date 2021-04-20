set -x

terraform -chdir=${module_path} fmt -no-color -check -diff -recursive


