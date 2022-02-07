# Terraform Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/terraform-v2)](https://circleci.com/orbs/registry/orb/ovotech/terraform-v2)

This orb can be used to plan and apply terraform modules.
It is published as `ovotech/terraform-v2@2`.

**Note: this orb only supports terraform `>=0.14`.**

If you're upgrading from terraform orb v1, see
[the upgrade guide](v1-to-v2.md).

## Executors

The orb provides executors for running terraform commands.
An executor defines the docker image to use for jobs.

### default

[Dockerfile](executor/Dockerfile)

It contains:
- tfmask
- tfswitch
- google-cloud-sdk
- aws-cli
- Helm 3+ available as `helm` and `helm3` See [Using Helm 3](https://github.com/ovotech/circleci-orbs/tree/master/terraform-v2#Using-Helm-3)
- stable "ovo" provider with ovo_kafka_user resource (`source = "terraform.ovotech.org.uk/pe/ovo"`)
- stable "aiven-kafka-users" provider with aiven-kafka-users_user resource that enables auto-rotation of credentials  (`source = "terraform.ovotech.org.uk/pe/aiven-kafka-users"`)


## Commands

Terraform can obtain credentials from environment variables set in
circleci.

For the AWS provider, set the AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY
environment variables.

For the gcloud provider, set GCLOUD_SERVICE_KEY to be a GCP service
account key as a base64 encoded or plain text string.
You may optionally set GOOGLE_PROJECT_ID to the ID of the project
running the cluster. If you have provided the project ID then you
may set GOOGLE_COMPUTE_ZONE too — **you cannot set zone on its own**.

If GITHUB_USERNAME and GITHUB_TOKEN environment variables are set,
the `plan` command will add a comment on an open PR with the plan.

By default, when using the `apply` command the plan must have been approved
by being merged from a PR that has had a comment added by a previous `plan` command.
If the plan is not found or has drifted, then the `apply` command will fail.

This is to ensure that the orb only applies changes that have been reviewed by a human.

You can disable this behaviour by setting `auto_approve: true` in the `apply` step,
which will always apply any terraform changes.

See (the orb doc)[https://circleci.com/developer/orbs/orb/ovotech/terraform#commands]
for a list of available commands.

## Jobs

See (the orb doc)[https://circleci.com/developer/orbs/orb/ovotech/terraform#jobs]
for a list of available jobs.

These jobs run their respective command in the default executor.
The jobs have the same parameters as the commands.

## Examples

### A simple example

In this example a plan for the module in tf/ is generated and attached
to the open PR. If that PR is then merged, the plan is applied.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform-v2@2

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
  terraform: ovotech/terraform-v2@2

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
          helm repo add helm-example gs://<my_google_bucket>/

    - terraform/plan:
        path: terraform/deployments/cluster
        workspace: helm-example-uat
    - terraform/plan:
        path: terraform/deployments/cluster-init
        workspace: helm-example-uat
    - terraform/plan:
        path: terraform/deployments/helm-example-uat

    - terraform/plan:
        path: terraform/deployments/cluster
        workspace: helm-example-prd
    - terraform/plan:
        path: terraform/deployments/cluster-init
        workspace: helm-example-prd
    - terraform/plan:
        path: terraform/deployments/helm-example-prd

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
          helm repo add helm-example gs://<my_google_bucket>/

    - terraform/apply:
        path: terraform/deployments/cluster
        workspace: helm-example-uat
    - terraform/apply:
        path: terraform/deployments/cluster-init
        workspace: helm-example-uat
    - terraform/apply:
        path: terraform/deployments/helm-example-uat

    - terraform/apply:
        path: terraform/deployments/cluster
        workspace: helm-example-prd
    - terraform/apply:
        path: terraform/deployments/cluster-init
        workspace: helm-example-prd
    - terraform/apply:
        path: terraform/deployments/helm-example-prd

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

### Using Helm 3

#### Repositories
If you are using Helm 3 (terraform provider > v1) you must explicitly add
repositories, this includes charts in `stable` which is no longer included 
in Helm by default. 

[Official Documentation](https://helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository)

This can be done using the `helm3` command prior to any apply jobs.

```yaml
  terraform_apply:
    executor: terraform/default
    steps:
    - checkout
    - run:
        name: Add helm repo
        command: |
            helm3 repo add stable https://kubernetes-charts.storage.googleapis.com
            helm3 repo update

    - terraform/apply:
        path: terraform/deployments/cluster
        workspace: helm-example-uat
```

#### Default version
The `helm` command will use `helm3` by default.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform-v2@2

jobs:
  terraform_plan:
    executor: terraform/default
    environment:
      AIVEN_PROVIDER: true
    steps:
      - checkout
      - terraform/plan:
          path: tf

workflows:
  test:
    jobs:
      - terraform_plan:
          filters:
            branches:
              ignore: master
```

### Checking for changes

This examples checks the infrastructure every morning. If changes are
detected to any of the terraform resources the build is failed.

```yaml

version: 2.1

orbs:
  terraform: ovotech/terraform-v2@2

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

To attach the plan to a PR, create the GITHUB_USERNAME and GITHUB_TOKEN
environment variables in the CircleCI project. This should be the username
(not email address) and a Personal Access Token of a github user that has access to
the repo. The token requires the `repo, write:discussion` scopes.

It's recommended to enable **"Only build pull requests"**  in your CircleCI 
config when using this setting. If not enabled this could lead to a creation
of a PR after the CircleCI job has run, which means the Plan comment cannot be
added. Settings can be found under "Advanced Settings" e.g.
https://circleci.com/gh/ovotech/$YOUR_REPO/edit#advanced-settings

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

## Private Terraform Module Registries

You can use this orb with private Terraform Module registries.

To specify the registry api token, set TF_REGISTRY_HOST and
TF_REGISTRY_TOKEN environment variables in the CircleCI settings.

## Masking of sensitive values

The terraform commands use [tfmask](https://github.com/cloudposse/tfmask) to mask sensitive output for these resources:

- random_id
- kubernetes_secret
- acme_certificate

You can customise this list using the TFMASK_RESOURCES_REGEX environment variable. See the tfmask docs for details.
Please create a github issue to suggest additional resources that need masking.

## Specifying a terraform version

The version of terraform to use is discovered from the first of:
1. A [`required_version`](https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version)
   constraint in the terraform configuration.
2. A [tfswitch](https://warrensbox.github.io/terraform-switcher/) `.tfswitchrc` file
3. A [tfenv](https://github.com/tfutils/tfenv) `.terraform-version` file in path of the terraform
   configuration.

The `required_version` constraint goes somewhere in your terraform configuration:
```hcl
terraform {
  required_version = "0.15.0"
}
```

tfswitch and tfenv make it easy to install the correct version locally.  
Their config files contain a terraform version number to use:
```
0.15.0
```
