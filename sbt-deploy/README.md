# SBT Deploy Orb

Allows automatic deployment of services via a job which updates a specified gitops repo with the latest service image tags.

Requires the K8s cluster to be configured with Argo and Kustomize.

## Prerequisites

- Github deploy key with push rights to the gitops repo needs to be added to the `Additional SSH keys` setting in consuming CircleCI project.
  - The host name should be "github.com".

## Parameters

| Parameter                  | Required |       Default        | Description                                 |
| -------------------------- | :------: | :------------------: | ------------------------------------------- |
| environment                |   Yes    |          -           | Which env to deploy within                  |
| service-name               |   Yes    |          -           | User readable service name                  |
| service-image-new-name     |   Yes    |          -           | Image URI excluding tag                     |
| service-image-new-tag      |   Yes    |          -           | Tag of image to deploy                      |
| gitops-ssh-key-fingerprint |   Yes    |          -           | SSH key to allow gitops repo update         |
| gitops-repo                |   Yes    |          -           | Gitops repository URI                       |
| gitops-deploy-branch       |    No    |        `main`        | Gitops repository branch to make changes to |
| gitops-username            |   Yes    |          -           | Username to associate with git actions      |
| gitops-email               |   Yes    |          -           | Email to associate with git actions         |
| gitops_overlay_path        |   Yes    |          -           | Path to kustomize overlay to be updated     |
| service-image-current-name |    No    | `SERVICE_IMAGE_NAME` | Placeholder image name text in manifest     |

## Example Usage

```yaml
orbs:
  sbt-deploy: ovotech/sbt-deploy@0.1.1

jobs:
  deploy-to-uat:
    machine:
      image: ubuntu-2004:202101-01
    steps:
      - sbt-deploy/deploy-service:
          environment: non-prod
          service-name: public-api
          service-image-new-name: XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/public-api
          service-image-new-tag: 1.23.4
          gitops-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops-repo: git@github.com:ovotech/placeholder-repo.git
          gitops-username: CircleCI deploy bot
          gitops-email: deploy-bot@circleci.ovotech.org.uk
          gitops_overlay_path: overlays/non-prod
```
