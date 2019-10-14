# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed.

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
