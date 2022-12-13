# Terraform Registry Orb

Orb to perform the following operations against Terraform Cloud:

| Command              | Description                                                       |
| ---------------------| ------------------------------------------------------------------|
| setup                | Configure and store Terraform Cloud credentials in `.terraformrc` |
| publish-module       | Publish a new module version to Terraform Cloud                   |
| module-version-check | Determines if a module version has not already been published     |


## setup

The setup command creates a `.terraformrc` file and writes the supplied
API token.  The environment variable defaults to `TF_CLOUD_TOKEN`

```yaml
version: '2.1'
orbs:
  terraform-registry: ovotech/terraform-registry@1

executors:
  base:
    docker:
      - image: "cimg/base:current"

jobs:
  terraform-cloud-setup:
    executor: base
    steps:
      - terraform-registry/setup
```

## publish-module

Publishes a new version of a module to Terraform Cloud.  Please note that
before you can publish a module version you must register your module
using the `terraform-cloud-as-code` repository.  Notes
[here](https://github.com/ovotech/terraform-cloud-as-code/blob/main/PUBLISHING_MODULES.md)

```yaml
version: '2.1'
orbs:
  terraform-registry: ovotech/terraform-registry@1

executors:
  base:
    docker:
      - image: "cimg/base:current"

jobs:
  publish-module:
    executor: base
    steps:
      - terraform-registry/publish-module:
          provider-name: aws
          module-name: cppe-s3-bucket
          module-version: 1.0.1
          module-path: /path/to/module

```

## module-version-check

Determines if a module version has not already been published.  Returns a
non-zero exit code if the module version already exists.

```yaml
version: '2.1'
orbs:
  terraform-registry: ovotech/terraform-registry@1

executors:
  base:
    docker:
      - image: "cimg/base:current"

jobs:
  module-version-check:
    executor: base
    steps:
      - terraform-registry/module-version-check:
          provider-name: aws
          module-name: cppe-s3-bucket
          module-version: 1.0.1
```
