#!/usr/bin/env bash

terraform -chdir=${module_path} workspace select -no-color "default"
terraform -chdir=${module_path} workspace delete -no-color -lock-timeout=300s "$workspace"
