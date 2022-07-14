KAP KMI [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/kap-kmi-deploy)](https://circleci.com/orbs/registry/orb/ovotech/kap-kmi-deploy)
=====================

Provides commands for deploying images to the KAP KMI registry and pushing those images to KMI.

Overview
--------

### Commands

* `deploy-image` - builds and pushes a new docker image to the KAP ECR registry.
* `update-gitops` - updates the KAP/KMI deployment manifest for the specified service to use a specified image from the KAP ECR registry.

### Jobs

* `deploy` - combines the two commands to build, push and deploy a new docker image of a given KAP service to KMI.

### Prerequisites

Mandatory environment variables:

* `AWS_ACCESS_KEY_ID` - for read/write access to the ECR registry.
* `AWS_SECRET_ACCESS_KEY` - for read/write access to the ECR registry.
* `KAP_GITOPS_USERNAME`
* `KAP_GITOPS_EMAIL`

Core environment variables in use by the orb:

* `CIRCLE_PROJECT_REPONAME` - used as the default for `service-name`, `image-name` and `kmi-k8s-namespace`
* `CIRCLE_SHA1` - used as a suffix to the image tag used.

You will also need the SSH key appropriate for gitops operations added as an SSH key in your project settings in CircleCI:

1. In Circle CI, navigate to your Circle CI _Project Settings_.
2. Navigate to _SSH Keys_ -> _Additional SSH Keys_.
3. Add a new "additional" SSH key (hostname "github.com"). The key itself should be available from the maintainers of the KAP infra.

Example
-------

> The examples below assume that the git repository name matches the `service-name`, `image-name` and `kmi-k8s-namespace`
> parameters - if it does not these parameters should be explicitly declared.

Using the `deploy` job:

```yaml
orbs:
  kmi-deploy: ovotech/kap-kmi-deploy@1.0.0

workflows:
  version: 2.1
  service-deploy:
    jobs:
      - kmi-deploy/deploy:
          name: kmi-deploy-uat
          environment: uat
          push-image: true
      - kmi-deploy/deploy:
          name: kmi-deploy-prod
          environment: prod
          requires:
            - kmi-deploy-uat
```

For more granular control using the commands:

```yaml
orbs:
  kmi-deploy: ovotech/kap-kmi-deploy@1.0.0

jobs:
  deploy:
    executor: kmi-deploy/default
    steps:
      - kmi-deploy/deploy-image
      - kmi-deploy/update-gitops:
          environment: prod
          gitops-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops-username: my-bot
          gitops-email: my-bot@myco.co.uk
```
