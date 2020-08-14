OOT EKS Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/oot-eks)](https://circleci.com/orbs/registry/orb/ovotech/oot-eks)
=====================

Provides commands for packaging and deploying images to [AWS EKS](https://aws.amazon.com/eks/).

It is quite opinionated about what files exist and where. Here is a summary:

* A file called `kubernetes/deployment.yaml` is expected to exist describing the [kubernetes deployment](https://v1-17.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.17/#deployment-v1-apps).
* An [AWS ECR registry](https://aws.amazon.com/ecr/) with the same name as the service being deployed exists on the same AWS account.  
