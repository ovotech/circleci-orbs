# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed

## ovotech/terraform-v2@2.4.4

- Revert collapsed plans (2.4.3)

## ovotech/terraform-v2@2.4.3
- Plan comments in github PR now appear in a collapsed `<details>` markdown tag which reduces PR comment thread noise (while still being able to view the whole plan if needed)

## ovotech/terraform-v2@2.4.2
- Disabled printing of commands in the publish script

## ovotech/terraform-v2@2.4.1
- Add string to match terraform plans on with version 1+

## ovotech/terraform-v2@2.4.0
- Update terraform publish to upload to S3 presigned URL

## ovotech/terraform-v2@2.3.0
- Prevent module versions being overwritten

## ovotech/terraform-v2@2.1.1
- Added Terraform provider Aiven Kafka Users v1.0.2 v1.0.3

## ovotech/terraform-v2@2.1.0
- Add terraform version check that fails the build with a helpful
  message if the terraform version <0.14.

## ovotech/terraform-v2@2.0.0
- Start of the changelog
