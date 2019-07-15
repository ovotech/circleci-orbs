# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed.

## [1.5.0]
### Added
- Specific terraform versions can be specified using a [tfswitch](https://warrensbox.github.io/terraform-switcher/) 
`.terraformrc` or [tfenv](https://github.com/tfutils/tfenv) `.terraform-version` file in the module path
  This allows you to use newer terraform versions without waiting for a new orb version, and also doesn't force you to upgrade with new orb versions
- A `validate` command that validates a terraform module for correctness
- A `fmt-check` command that checks terraform files in a directory are in canonical format
- A `version` command that prints the terraform version and versions of terraform plugins used
- An `in-workspace` command to execute custom steps inside an initialized terraform working directory 
- The `plan` command has gained the `add_github_comment` boolean parameter to disable commenting

### Changed
- `terraform-0_12` executor updated to use terraform `0.12.5` as the default
- The `GCLOUD_SERVICE_KEY` no longer needs to be base64 encoded. (But still may be)
- Empty plans will now result in a comment on GitHub
- The GitHub comment will be updated with the outcome of the apply
- Empty plans will still be applied, to ensure changes to outputs are stored

## [1.4.43]
Start of the changelog
