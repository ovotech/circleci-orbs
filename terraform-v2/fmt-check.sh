#!/usr/bin/env bash

terraform -chdir=${module_path} fmt -no-color -check -diff -recursive


