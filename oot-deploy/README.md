OOT Deploy Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/oot-eks)](https://circleci.com/orbs/registry/orb/ovotech/oot-deploy)
=====================

Provides commands for packaging and deploying OOT images via [ArgoCD](https://argoproj.github.io/argo-cd/) and our gitops repo.

The gitops repo is expected to have the structure:

```
<root>
    - templates
        - <service1>
            - manifest.yaml
        - <service2>
            - manifest.yaml
        ...
        - <serviceN>
            - manifest.yaml
```

What it does:

1. Builds a new image based on the current project and pushes to an ECR registry named after the `service` parameter within the AWS account indicated by the `account` parameter.
2. Clones the specified gitops repo. Then from within that cloned folder:
3. Copies `./templates/<service>/manifest.yaml` to the `./<environment>/<service>/manifest.yaml`
    - The `./<environment>/<service>` folder will be created if it does not already exist.
4. Interpolates placeholders within  `./<environment>/<service>/manifest.yaml` as:
    - `{{AWS_ACCOUNT_ID}}` will be swapped for the value of the `account` parameter.
    - `{{ENVIRONMENT}}` will be swapped for the value of `environment` parameter.
    - `{{IMAGE_TAG}}` will be swapped for the core CircleCI environment variable `${CIRCLE_SHA1}`
5. Pushes the changes to the gitops repo as the github user `<gitops-username>`.

From there, as long as the prerequisites below are configured properly, Argo should take over and pull the changes from `./<environment>/<service>/manifest.yaml`
and deploy them to your kubernetes cluster.

Prerequisites
-------------
* The source project is configured in Argo such that Argo watches the `./<environment>/<service>` folder for updates to deploy.  
* A deploy key with push rights to the gitops repo has been assigned under "Additional SSH keys" in this source project.
    - The host name should be "github.com".
    - The fingerprint of this deploy key is the one used as the value of the `gitops-ssh-key-fingerprint` parameter.

Example
-------

```yaml
orbs:
  oot-deploy: ovotech/oot-deploy@1.0.0

jobs:
  push-nonprod:
    executor: oot-deploy/aws
    steps:
      - oot-deploy/push:
          service: my-service
          environment: nonprod
          account: "1234567890"
          gitops-repo: git@github.com:ovotech/my-gitops.git
          gitops-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops-username: my-bot
          gitops-email: my-bot@myco.co.uk
```

This is what will happen upon running the `oot-deploy/push` command:

1. A new image based on the current project source being deployed to an ECR registry called "my-service" within the AWS account 1234567890
2. The gitops repo `git@github.com:ovotech/my-gitops.git` will be cloned; and then from within that folder...
3. The `./templates/my-service/manifest.yaml` will be copied to `./nonprod/my-service/manifest.yaml` (the folder will be created if it does not already exist)
4. `./nonprod/my-service/manifest.yaml` will be interpolated as described above.
5. The changes to the gitops repo will be pushed as the github user `my-bot`.

From there, Argo will take over. 