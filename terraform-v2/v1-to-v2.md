# Upgrading From Terraform Orb V1 To V2

## Why V2?

Version management tools such as `tfswitch` and `tfenv`, alongside the
`required_version` terraform config setting, now seem to be relatively
common-place, and remove the need for new Docker image/executors to be curated
for each minor version of terraform.

We’d like to keep the orb source code as simple as possible, whilst implementing
new Terraform flags/features. Having different code paths based on the Terraform
version has been steadily increasing the required complexity.

We are taking advantage of some removals in terraform `0.15` which
break the terraform v1 orb. We would like to fix those removals in v2 only,
resulting in a situation where the terraform v1 orb supports terraform `<=0.14`
and terraform v2 supports terraform `>=0.14`.

## How Has V2 Been Split From V1?

In an attempt to continue supporting orb v1 in the short term, we’ve created an
entirely new orb called “terraform-v2”. We can maintain both major versions
from the same codebase.

Upgrading is therefore entirely in the control of the user, no-one will be 
automatically upgraded.

## Pre-requisites To Upgrading

Before upgrading, you must ensure you meet the following criteria:

- Running terraform >=0.14
- Managing terraform version using `tfswitch`, `tfenv` or `required_version`
- If running Helm commands in the container prior to any terraform commands,
ensure you're using Helm3, not Helm2
- Ensure you're not using the `use_chdir` orb parameter (introduced as an
optional parameter in orb v1 in version `1.8.3`)

## How To Upgrade From V1 to V2

You'll need to update the orb stanza in your .circleci/config.yml file:

```yaml
orbs:
  terraform: ovotech/terraform-v2@1
```

This will use the latest 1.x.x version of the v2 orb, you can pin to a more
precise version, e.g. 1.0 or 1.0.0 if required.

Ensure you specify the default executor:

```yaml
    executor: terraform/default
```

## Details Of Breaking Changes

- **`use_chdir` orb parameter removed**

Terraform 0.15 removed the ability to put a path at the end of a terraform
command in order to run that command relative to that directory. From terraform
0.14 onwards, the terraform recommended way to do this is by using the -chdir
option. `use_chdir` was introduced to the v1 orb to allow users of terraform
0.14 to use -chdir if they wanted. The terraform v2 orb only supports terraform
`>=0.14` so it uses -chdir in all cases, never placing the terraform directory
path at the end of the command. As such the `use_chdir` param is no longer
relevant.


- **Version manager required**

As detailed <here>, you can use tfswitch, tfenv or required_version config
setting to tell the orb which terraform version you’d like to use.


- **Support for terraform <0.14 removed**

The -chdir option was introduced in terraform 0.14. The final positional
argument as the directory path to run terraform in was removed in terraform
0.15, with -chdir as the replacement. The v2 orb only uses -chdir to specify
the terraform directory, which is incompatible with terraform <0.14. A number
of adaptations for older versions have also been removed. These are: 
- Removing the `-check-variables` check in validate
- Changing the `var-file` and `backend-config-file` behaviour to always provide
the path relative to the config directory, rather than from the root directory
(for compatibility with chdir)
- Using -recursive with terraform fmt (introduced in terraform 0.12)
