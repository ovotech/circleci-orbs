# Changelog
All notable changes to the orb will be documented in this file.
Orbs are immutable, some orb versions with no significant changes are
not listed

## ovotech/terraform-v2@2.4.12
- Added Terraform provider Aiven Kafka Users v1.0.8 to all executors

## ovotech/terraform-v2@2.4.11
- Added Terraform provider Aiven Kafka Users v1.0.7 to all executors

## ovotech/terraform-v2@2.4.10
- Added Terraform provider Aiven Kafka Users v1.0.6 to all executors

## ovotech/terraform-v2@2.4.9
- Added reuse_plan for apply step

## ovotech/terraform-v2@2.4.8
- Added Terraform provider Aiven Kafka Users v1.0.5 to all executors

## ovotech/terraform-v2@2.4.7
- Added Terraform provider Aiven Kafka Users v1.0.4 to all executors

## ovotech/terraform-v2@2.4.6
- Prevent lack of trailing newline chars from breaking Terraform operations

## ovotech/terraform-v2@2.4.5
- Reimplements 2.4.3 and fixes bug causing comparing apply-time plan to PR plan to fail

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
