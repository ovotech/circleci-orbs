# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed.

## ovotech/terraform@1.5.0
### Added
- Support for terraform module registry authorization using the TF_REGISTRY_HOST and TF_REGISTRY_TOKEN environment variables.
- The `publish-module` orb command, for publishing a module to a terraform registry.

## ovotech/terraform@1.4.46
### Added
- Specific terraform versions can be specified using a [tfswitch](https://warrensbox.github.io/terraform-switcher/) 
`.terraformrc` or [tfenv](https://github.com/tfutils/tfenv) `.terraform-version` file in the module path.

  This allows you to use newer terraform versions without waiting for a new orb version, and also doesn't force you to upgrade with new orb versions.

### Changed
- `terraform-0_12` executor updated to use terraform `0.12.4` as the default.

## ovotech/terraform@1.4.43
Start of the changelog
