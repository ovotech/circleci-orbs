# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed

## ovotech/terraform@1.8.2
## Fixed
- Helm 2 init failing as the stable and incubator repositories have moved to a new location
    - Added stable-repo-url option to helm init with new repo

## ovotech/terraform@1.8.1
## Fixed
- PR comment plan is empty with Terraform 0.14.0

## ovotech/terraform@1.8.0
## Changed
- Updated terraform-0.13 executor to include:
    - in-house ovo provider location compatible with required_providers syntax in 0.13
    - in-house aiven-kafka-users provider location compatible with required_providers syntax in 0.13

## ovotech/terraform@1.7.9
## Changed
- Updated executors to include:
    - gcloud 314.0.0

## ovotech/terraform@1.7.8
## Changed
- Added HCL syntax highlighting

## ovotech/terraform@1.7.7
## Changed
- Revert HCL syntax highlighting

## ovotech/terraform@1.7.6
## Changed
- Added HCL syntax highlighting

## ovotech/terraform@1.7.5
## Changed
- Added terraform-provider-aiven-kafka-users v0.0.1

## ovotech/terraform@1.7.4
## Changed
- Add new TF 0.13.x vers and Aiven providers

## ovotech/terraform@1.7.3
## Changed
- Updated `helm`, `helm2` and `awscli` packages for 0.12, 0.12-slim and 0.13 executors
- Updated default Terraform version for 0.13 executor to use 0.13.2
- Added newest Terraform versions to 0.13 executor

## ovotech/terraform@1.7.2
### Changed
- Updated 0.12 slim executor with Aiven's terraform-provider-aiven 2.0.1 

## ovotech/terraform@1.7.1
### Changed
- Added slim Terraform 0.12 executor 
  This image contains one version of each provider/tool

## ovotech/terraform@1.7.0
### Changed
- Added Terraform 0.13 executor

## ovotech/terraform@1.6.10
### Changed
- No changes to Orb, latest tfmask to be cloned, built and added to Docker image at build time.

## ovotech/terraform@1.6.9
### Changed
- Updated Terraform to the latest version 0.12.29
- Updated default Terraform version 0.12.5 -> 0.12.29

## ovotech/terraform@1.6.8
### Changed
- Updated executors to include helm2 @v2.16.9
- Terraform commands will now keep trying to obtain the state lock for 5 minutes instead of failing immediately.

## ovotech/terraform@1.6.7
### Changed
- Updated tfswitch to 0.8.832.
  This will use any required_version constraint in the terraform config to pick the terraform version to use.

## ovotech/terraform@1.6.6
### Changed
- Added `TFENV` env var to 0.11 Docker image, as `tfmask` now defaults to tf 0.12

## ovotech/terraform@1.6.5
### Changed
- Updated executors to include:
    - wget
    
## ovotech/terraform@1.6.4
### Changed
- Updated executors to include:
    - helm3 @ v3.0.3
    - Aiven's aiven-provider-terraform 1.1.4
    - gcloud 279.0.0
    - awscli 1.17.11

## ovotech/terraform@1.6.3
### Changed
- Updated executors to include:
    - terraform 0.12.20
    - Aiven's aiven-provider-terraform 1.1.1, 1.1.2, 1.1.3
    - gcloud 277.0.0
    - awscli 1.17.9

## ovotech/terraform@1.6.2

### Changed
- Updated executors to include:
    - Aiven's aiven-provider-terraform 1.0.20, 1.1.0
    
### Fixed
- Older versions of aiven-provider that were accidentally left out of 1.6.1 have been restored

## ovotech/terraform@1.6.1
### Changed
- Updated executors to include:
    - Aiven's aiven-provider-terraform 1.0.19

## ovotech/terraform@1.6.0
### Added
- An `output_path` parameter to the `apply` command, for saving output variables to a json file
- A separate `output` command that writes output variables from a terraform state to a json file
- Helm 3.0.0 is included in the executors as `helm3`. You can make helm3 the default version by setting the
  environment variable `HELM=helm3`.

### Changed
- Updated executors to include:
    - terraform 0.12.17
    - awscli 1.16.294

## ovotech/terraform@1.5.13
### Changed
- Updated executors to include:
    - terraform 0.12.14, 0.12.15, 0.12.16
    - gcloud 272.0.0
    - awscli 1.16.284
    - helm 2.16.1

## ovotech/terraform@1.5.12
### Changed
- Updated executors to include:
    - terraform 0.12.13
    - gcloud 270.0.0
    - awscli 1.16.274
    - helm 2.15.2

## ovotech/terraform@1.5.11
### Changed
- Updated executors to include:
    - terraform 0.12.12
    - gcloud 268.0.0
    - awscli 1.16.265
    - helm 2.15.1

## ovotech/terraform@1.5.10
### Changed
- Updated executors to include:
    - terraform 0.12.10
    - gcloud 266.0.0
    - awscli 1.16.258

## ovotech/terraform@1.5.9
### Changed
- Updated executors to include:
    - terraform 0.12.9
    - gcloud 265.0.0
    - awscli 1.16.249
    - Aivens' aiven-provider-terraform 1.0.17
    
## ovotech/terraform@1.5.8
### Changed
- Updated executors to include:
    - terraform 0.12.8
    - gcloud 262.0.0
    - awscli 1.16.238
    - Aivens' aiven-provider-terraform 1.0.16

## ovotech/terraform@1.5.7
### Changed
- Updated executors to include:
    - terraform 0.12.7
    - gcloud 260.0.0
    - awscli 1.16.230
    - Ovo's kafka user provider 1.0.0
    - Aivens' aiven-provider-terraform 1.0.15 (with data sources!)

## ovotech/terraform@1.5.5
### Changed
- Added link to CircleCI build at bottom of plan

## ovotech/terraform@1.5.4
### Changed
- Updated executors with aiven-provider-terraform 1.0.13

## ovotech/terraform@1.5.3
### Fixed
- Updated terraform executor to allow `terraform init` when a workspace does not yet exist

## ovotech/terraform@1.5.2
### Changed
- Updated executors to include:
    - terraform 0.12.6
    - gcloud 256.0.0
    - awscli 1.16.210
    - helm 2.14.3
- The GitHub comment is updated earlier when applying a change
- The GitHub comment is updated when an apply fails

## ovotech/terraform@1.5.1
### Changed
- Add GitHub link to orb description

### Fixed
- The publish-module command label was wrong

## ovotech/terraform@1.5.0
### Added
- A `validate` command that validates a terraform module for correctness
- A `fmt-check` command that checks terraform files in a directory are in canonical format
- A `version` command that prints the terraform version and versions of terraform plugins used
- An `in-workspace` command to execute custom steps inside an initialized terraform working directory
- The `plan` command has gained the `add_github_comment` boolean parameter to disable commenting
- Support for terraform module registry authorization using the TF_REGISTRY_HOST and TF_REGISTRY_TOKEN environment variables
- The `publish-module` orb command, for publishing a module to a terraform registry

### Changed
- `terraform-0_12` executor updated to use terraform `0.12.5` as the default
- The `GCLOUD_SERVICE_KEY` no longer needs to be base64 encoded (but still may be)
- Plans with no changes will now result in a comment on GitHub
- The GitHub comment will be updated with the outcome of the apply
- Plans with no changes will now be applied, to ensure changes to outputs are stored

## ovotech/terraform@1.4.46
### Added
- Specific terraform versions can be specified using a [tfswitch](https://warrensbox.github.io/terraform-switcher/) 
`.terraformrc` or [tfenv](https://github.com/tfutils/tfenv) `.terraform-version` file in the module path

  This allows you to use newer terraform versions without waiting for a new orb version, and also doesn't force you to upgrade with new orb versions.

## ovotech/terraform@1.4.43
Start of the changelog
