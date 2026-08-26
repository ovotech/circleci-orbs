#!/usr/bin/env bash

terraform -chdir=${module_path} workspace select -no-color "${workspace}"
