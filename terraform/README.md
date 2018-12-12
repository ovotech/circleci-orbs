# Terraform Orb

This orb can be used to plan and apply terraform modules.
It is published as ovotech/terraform@1

## Executors

The orb provides an executor for running terraform commands.
This defines a docker image to use for jobs.

### default

The executor is named 'default'

It also contains:
- ovo's terraform-provider-aiven
- helm + terraform-provider-helm
- terraform-provider-acme
- google-cloud-sdk
- aws-cli

## Commands

Terraform can obtain credentials from environment variables set in
circleci.

For the AWS provider, set the AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY
environment variables.

For the gcloud provider, set GCLOUD_SERVICE_KEY to be a base64-encoded
GCP service account key. You can also set GOOGLE_PROJECT_ID and
GOOGLE_COMPUTE_ZONE.

If GITHUB_USERNAME and GITHUB_TOKEN environment variables are set, a comment
is made on an open PR with the plan. Merging the PR approves the plan.

If github credentials are not set the apply step will fail, as it can't
find the approved plan. You can instead set auto_approve to true to
apply the current plan anyway.

### plan

This command runs the terraform plan command.

Parameters:

- path: Path the the terraform module to run the plan in
- workspace: Terraform workspace to run the command in (default: 'default')
- environment: A friendly name for the environment this plan is for. This must be set if there are multiple plans in a job with the same path and workspace.
- backend_config_file: Comma separated list of terraform backend config files
- backend_config: Comma separated list of backend configs, e.g. foo=bar
- var_file: Comma separater list of terraform var files
- var: Comma separated list of vars to set, e.g. foo=bar

### apply

This command runs the terraform apply command.

Parameters:

- path: Path the the terraform module to run the plan in
- workspace: Terraform workspace to run the command in (default: 'default')
- environment: A friendly name for the environment this apply is for. This must be the same as the environment of the corresponding plan command.
- backend_config_file: Comma separated list of terraform backend config files
- backend_config: Comma separated list of backend configs, e.g. foo=bar
- var_file: Comma separater list of terraform var files
- var: Comma separated list of vars to set, e.g. foo=bar
- auto_approve: Apply the plan, even if it has not been approved through a PR.

### check

This command runs the terraform plan command, and fails the build if any
changes are required. This is intended to run on a schedule to notify if
manual changes to your infrastructure have been made.

Parameters:

- path: Path the the terraform module to run the plan in
- workspace: Terraform workspace to run the command in (default: 'default')
- backend_config_file: Comma separated list of terraform backend config files
- backend_config: Comma separated list of backend configs, e.g. foo=bar
- var_file: Comma separater list of terraform var files
- var: Comma separated list of vars to set, e.g. foo=bar

## Jobs

This orb contains plan, apply and check jobs which run their respective
command in the default executor.

The jobs have the same parameters as the commands.

## Examples

### A simple example

In this example a plan for the module in tf/ is generated and attached
to the open PR. If that PR is then merged, the plan is applied.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform@1

workflows:
  test:
    jobs:
      - terraform/plan:
          path: tf
          filters:
            branches:
              ignore: master

      - terraform/apply:
          path: tf
          filters:
            branches:
              only: master
```

### A real-world example

This configuration defines it's own plan and apply jobs which use the
orb's plan and apply commands on multiple terraform modules.
It also configures a helm repo within the the container for use with the
terraform helm provider.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform@1

jobs:
  terraform_plan:
    executor: terraform/default
    steps:
    - checkout
    - run:
        name: Add helm repo
        command: |
          echo $GOOGLE_SERVICE_ACCOUNT | base64 -d > /tmp/google_creds
          export GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_creds
          gcloud auth activate-service-account --key-file=/tmp/google_creds
          helm plugin install https://github.com/nouney/helm-gcs --version 0.1.4
          helm repo add gauges gs://gauges-helm-repo/

    - terraform/plan:
        path: terraform/deployments/cluster
        workspace: gauges-uat
    - terraform/plan:
        path: terraform/deployments/cluster-init
        workspace: gauges-uat
    - terraform/plan:
        path: terraform/deployments/gauges-uat

    - terraform/plan:
        path: terraform/deployments/cluster
        workspace: gauges-prd
    - terraform/plan:
        path: terraform/deployments/cluster-init
        workspace: gauges-prd
    - terraform/plan:
        path: terraform/deployments/gauges-prd

    - terraform/plan:
        path: terraform/deployments/sqs-test

  terraform_apply:
    executor: terraform/default
    steps:
    - checkout
    - run:
        name: Add helm repo
        command: |
          echo $GOOGLE_SERVICE_ACCOUNT | base64 -d > /tmp/google_creds
          export GOOGLE_APPLICATION_CREDENTIALS=/tmp/google_creds
          gcloud auth activate-service-account --key-file=/tmp/google_creds
          helm plugin install https://github.com/nouney/helm-gcs --version 0.1.4
          helm repo add gauges gs://gauges-helm-repo/

    - terraform/apply:
        path: terraform/deployments/cluster
        workspace: gauges-uat
    - terraform/apply:
        path: terraform/deployments/cluster-init
        workspace: gauges-uat
    - terraform/apply:
        path: terraform/deployments/gauges-uat

    - terraform/apply:
        path: terraform/deployments/cluster
        workspace: gauges-prd
    - terraform/apply:
        path: terraform/deployments/cluster-init
        workspace: gauges-prd
    - terraform/apply:
        path: terraform/deployments/gauges-prd

    - terraform/apply:
        path: terraform/deployments/sqs-test

workflows:
  commit:
    jobs:
      - terraform_plan:
          filters:
            branches:
              ignore: master
      - terraform_apply:
          filters:
            branches:
              only: master

```

### Checking for changes

This examples checks the infrastructure every morning. If changes are
detected to any of the terraform resources the build is failed.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform@1

workflows:
  nightly:
    triggers:
      - schedule:
          cron: "0 8 * * *"
          filters:
            branches:
              only:
                - master
    jobs:
      - terraform/check:
          path: prod

```

## GitHub

To make best use of this orb, require that the plan is always reviewed
before merging the PR to approve. You can enforce this in github by
going to the branch settings for the repo and enable protection for
the master branch:

1. Enable 'Require pull request reviews before merging'
1. Check 'Dismiss stale pull request approvals when new commits are pushed'
1. Enable 'Require status checks to pass before merging'
1. Select the 'ci/circleci: terraform_plan' check.
1. Enable 'Require branches to be up to date before merging'
1. In the CircleCI project advanced settings, enable 'Only build pull requests'.
