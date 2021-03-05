# SBT Deploy Orb

Allows automatic deployment of services via a job which updates a specified gitops repo with the latest service image tags.

Requires the K8s cluster to be configured with Argo and Kustomize.

## Prerequisites

- Github deploy key with push rights to the gitops repo needs to be added to the `Additional SSH keys` setting in consuming CircleCI project.
  - The host name should be the git repository host e.g. "github.com".
  - If the SSH key fingerprint is already being added before this job runs, it does not need to be specified.
  - If an SSH key already exists with the host name required, you can use a custom identifier by specifying `gitops-repo-ssh-key-host` and `gitops-repo-ssh-key-hostname` where the `host` is the custom identifier and `hostname` is the host name.

## Parameters

| Parameter                       | Required |   Default    | Description                                        |
| ------------------------------- | :------: | :----------: | -------------------------------------------------- |
| environment                     |   Yes    |      -       | Which env to deploy within                         |
| service-name                    |   Yes    |      -       | User readable service name                         |
| service-image-current-name      |   Yes    |      -       | Placeholder image name text in manifest            |
| service-image-new-name          |   Yes    |      -       | Image URI excluding tag                            |
| service-image-new-tag           |   Yes    |      -       | Tag of image to deploy                             |
| gitops-repo                     |   Yes    |      -       | Gitops repository URI                              |
| gitops-deploy-branch            |    No    |    `main`    | Gitops repository branch to make changes to        |
| gitops-username                 |   Yes    |      -       | Username to associate with git actions             |
| gitops-email                    |   Yes    |      -       | Email to associate with git actions                |
| gitops_overlay_path             |   Yes    |      -       | Path to kustomize overlay to be updated            |
| gitops-repo-ssh-key-fingerprint |    No    |      -       | SSH key to allow gitops repo update                |
| gitops-repo-ssh-key-host        |    No    |      -       | Custom host identifier for SSH key                 |
| gitops-repo-ssh-key-hostname    |    No    | `github.com` | SSH key host name if custom host identifier is set |

## Example Usage

```yaml
orbs:
  sbt-deploy: ovotech/sbt-deploy@1.1.0

jobs:
  deploy-to-uat:
    machine:
      image: ubuntu-2004:202101-01
    steps:
      - sbt-deploy/deploy-service:
          environment: non-prod
          service-name: public-api
          service-image-current-name: SOME_SERVICE_PLACEHOLDER
          service-image-new-name: XXXXXX.dkr.ecr.eu-west-1.amazonaws.com/public-api
          service-image-new-tag: 1.23.4
          gitops-repo: git@ghgitops:ovotech/placeholder-repo.git
          gitops-username: CircleCI deploy bot
          gitops-email: deploy-bot@circleci.ovotech.org.uk
          gitops_overlay_path: overlays/non-prod
          gitops-repo-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops-repo-ssh-key-host: ghgitops
          gitops-repo-ssh-key-hostname: github.com
```
