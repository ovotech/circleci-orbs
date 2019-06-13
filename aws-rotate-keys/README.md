# AWS CircleCI key rotate orb

This orb can be used to rotate AWS access keys and update corresponding CircleCI environment variables.
A common use case would be to set up a scheduled CircleCI job which rotates access keys for the used account.

## Executors
This orb defines a small 'default' executor for running the aws commands.
Any container that has aws cli and curl can run the this orb.

## Commands
### rotate
This is the only command available in this orb. It rotates the AWS access keys for the account specified as the `aws-username` parameter. In addition of rotating the keys, this command also updates the corresponding environment variables. In order to run this command, you need to make sure that the aws cli client is already authenticated.

**Parameters**
- `aws-username` - user name of the AWS account you want to rotate keys for
- `github-org` - name of the Github organisation the repository belongs to
- `github-repo` - name of the Github repository
- `circleci-token` - CircleCI API token used to update environment variables
- `aws-access-key-id-var` - name of the CircleCI environment variable which holds a value of the aws access key id, e.g. `AWS_ACCESS_KEY_ID`
- `aws-secret-access-key-var` - name of the CircleCI environment variable which holds a value of the aws secret access key, e.g. `AWS_SECRET_ACCESS_KEY`. 

## Examples
Make sure you have the following environment variables set up in CircleCI:
- CircleCI API token, e.g. `CIRCLECI_TOKEN`
- AWS access key id and a secret access key, e.g. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Your environment variables can have any name you want as long as you configure the aws cli and refrence correctly the names in the orb parameters (see the examples below).

The following example has the following CircleCI env vars `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` so they are automatically picked up by aws cli.

```yaml
version: 2.1

orbs:
  rotate-aws-keys: ovotech/aws-rotate-keys@1

jobs:
  rotate-aws-keys:
    steps:
      - rotate-aws-keys/rotate:
          aws-username: circleci-user
          github-org: github-org
          github-repo: github-repo-name
          circleci-token: $CIRCLECI_TOKEN
          aws-access-key-id-var: AWS_ACCESS_KEY_ID
          aws-secret-access-key-var: AWS_SECRET_ACCESS_KEY

workflows:
  version: 2
  rotate-weekly:
    triggers:
      - schedule:
          cron: "30 10 * * 3" # Every Wednesday at 10:30 UTC
          filters: { branches: { only: master } }
    jobs:
      - rotate-aws-keys
```

The following example uses the following CircleCI env variables `PROD_AWS_ACCESS_KEY_ID` and `PROD_AWS_SECRET_ACCESS_KEY` which are not automatically picked up by aws cli and therefore you need to set up the credentials manually.

```yaml
version: 2.1

orbs:
  rotate-aws-keys: ovotech/aws-rotate-keys@1

jobs:
  rotate-aws-keys:
    steps:
      - run:
          command: |
            export AWS_ACCESS_KEY_ID=$PROD_AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$PROD_AWS_SECRET_ACCESS_KEY
            export AWS_DEFAULT_REGION=$PROD_AWS_DEFAULT_REGION
      - rotate-aws-keys/rotate:
          aws-username: circleci-user
          github-org: github-org
          github-repo: github-repo-name
          circleci-token: $CIRCLECI_TOKEN
          aws-access-key-id-var: PROD_AWS_ACCESS_KEY_ID
          aws-secret-access-key-var: PROD_AWS_SECRET_ACCESS_KEY

workflows:
  version: 2
  rotate-weekly:
    triggers:
      - schedule:
          cron: "30 10 * * 3" # Every Wednesday at 10:30 UTC
          filters: { branches: { only: master } }
    jobs:
      - rotate-aws-keys
```
