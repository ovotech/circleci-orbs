# OOT EKS Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/oot-eks)](https://circleci.com/orbs/registry/orb/ovotech/oot-eks)

Provides commands for packaging images for deployment to [AWS EKS](https://aws.amazon.com/eks/).

## Prerequisites

- An [AWS ECR registry](https://aws.amazon.com/ecr/) with the same name as the service being deployed exists on the same AWS account.

## Example

```yaml
orbs:
  oot-eks: ovotech/oot-eks@2.0.0

jobs:
  push-image-nonprod:
    executor: oot-eks/aws
    steps:
      - oot-eks/push-image:
          service: my-service
          account: "1234567890"
```

This is what will happen upon running the `push-image-nonprod` job:

1. A new docker image is built from the current source.
2. The image is scanned for vulnerabilities by Snyk.
3. The image is pushed to an ECR registry called "my-service" within the AWS account 1234567890

This orb tests switching aws deployment authentication away from an iam user and towards our OIDC provider.

## Version note

Between version 2.3.0 and version 3.0.0 we moved to using the oidc provider for authentication rather than an AWS IAM user.
