SBT Deploy Orb

=========

Allows automatic deployment of services via a job which updates a specified gitops repo with the latest service image tags.

Requires the K8s cluster to be configured with Argo and Kustomize.

## Prerequisites

- Deploy key with push rights to the gitops repo needs to be added to "Additional SSH keys" in consuming CircleCI project.
  - The host name should be "github.com".

## Parameters

- environment [required]
- service-name [required]
- service-image-new-name [required]
- service-image-current-name [default: `SERVICE_IMAGE_NAME`]
- service-image-new-tag [default: ${CIRCLE_SHA1}]
- gitops-ssh-key-fingerprint [required]
- gitops-repo [default: `git@github.com:ovotech/smart-bookings-environments.git`]
- gitops-username [default: `SBT CircleCI User`]
- gitops-email [default: `circleci@sme-circleci.ovotech.org.uk`]
- gitops_overlay_path [default: `overlays/non-prod`]

## Example Usage

```yaml
orbs:
  sbt-deploy: ovotech/sbt-deploy@0.1.0

jobs:
  deploy-to-uat:
    executor: ???
    steps:
      - sbt-deploy/deploy-service:
          environment: non-prod
          service-name: public-api-bookings
          service-image-new-name: XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/public-api-bookings
          service-image-new-tag: 1.23.4
          gitops-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops_overlay_path: overlays/non-prod
```
