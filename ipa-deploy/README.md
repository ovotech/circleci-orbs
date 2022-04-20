# IPA Deploy Orb

Provides slack alert templates for CircleCI.

## Parameters

| Parameter              | Required |  Default   | Description                                      |
| ---------------------- | :------: | :--------: | ------------------------------------------------ |
| deploy_failed_template |    No    | (template) | The slack alert template for deployment failure. |

## Usage

Run the `load_templates` command. This exports and allows the use of a "SLACK_DEPLOY_FAILED_TEMPLATE" env var as the template
parameter for the slack orb's `notify` command.

```yaml
orbs:
  ipa-deploy: ovotech/ipa-deploy@1.0.1

jobs:
  load-slack-templates:
    steps:
      - ipa-deploy/load_templates
```
