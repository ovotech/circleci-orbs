# Terraform Registry Orb

Orb to perform the following operations against Terraform Cloud:

| Command                     | Description                                                       |
| ----------------------------| ------------------------------------------------------------------|
| setup                       | Configure and store Terraform Cloud credentials in `.terraformrc` |
| publish_module              | Publish a new module version to Terraform Cloud                   |
| check_module_publishability | Determines if a module version has not already been published     |


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

## publish_module

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
  publish_module:
    executor: base
    steps:
      - terraform-registry/publish_module:
          module_name: cppe-s3-bucket
          module_provider_name: aws
          module_version: 1.0.1
          module_path: /path/to/module

```

## check_module_publishability

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
  check_module_publishability:
    executor: base
    steps:
      - terraform-registry/check_module_publishability:
          module_name: cppe-s3-bucket
          module_provider_name: aws
          module_version: 1.0.1
```
