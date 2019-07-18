# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed.

## [Unreleased]
### Added
- Specific terraform versions can be specified using a [tfswitch](https://warrensbox.github.io/terraform-switcher/) 
`.terraformrc` or [tfenv](https://github.com/tfutils/tfenv) `.terraform-version` file in the module path.

  This allows you to use newer terraform versions without waiting for a new orb version, and also doesn't force you to upgrade with new orb versions.

### Changed
- `terraform-0_12` executor updated to use terraform `0.12.4` as the default.

## [1.4.43]
Start of the changelog

[Unreleased]: https://github.com/ovotech/circleci-orbs/tree/master/terraform
[1.4.43]: https://github.com/ovotech/circleci-orbs/tree/22eedc932d5d893f7c81b199a05defd10dc0c280/terraform
