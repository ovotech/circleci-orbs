# OOT Deploy Orb [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/ovotech/oot-deploy)](https://circleci.com/orbs/registry/orb/ovotech/oot-deploy)

Provides commands for packaging and deploying OOT images via our gitops repo. We use it with [ArgoCD](https://argoproj.github.io/argo-cd/) although
there is no hard dependency on that application.

The gitops repo is expected to have the structure:

```
<root>
    - templates
        - argo-applications
            - manifest.yaml
        - <service1>
            - manifest.yaml
        - <service2>
            - manifest.yaml
        ...
        - <serviceN>
            - manifest.yaml
```

- Each `manifest.yaml` template in the `./templates/<serviceX>` directories represents all the kubernetes resources deployed
  to the cluster for "serviceX". So, typically it will just be a single kubernetes "deployment" but could potentially have multiple resources.
  The template will be interpolated by the orb as described in the next section.
- The `./templates/argo-applications/manifest.yaml` is the template that will be used to define "applications" within Argo itself. See
  the Argo documentation on [declaritive setup](https://argoproj.github.io/argo-cd/operator-manual/declarative-setup) for more information. Specifically,
  the template must be of the form described in the [application.yaml](https://argoproj.github.io/argo-cd/operator-manual/application.yaml). The
  template will be interpolated by the orb as described in the next section.

> IMPORTANT: This does imply that a "argo-applications" application is setup by hand in the Argo console to listen to the
> content of the `./<environment>/argo-applications` folder. By syncing that application from within Argo, Argo will add
> the new applications defined in the manifests in the folder.

## What does the orb do?

1. Clone the specified gitops repo. Then from within that cloned folder:
2. Copies the service manifest template `./templates/<service>/manifest.yaml` to the service manifest `./<environment>/<service>/manifest.yaml`
   - The `./<environment>/<service>` folder will be created if it does not already exist.
3. Interpolates placeholders within the service manifest as:
   - `{{AWS_ACCOUNT_ID}}` will be swapped for the value of the `account` parameter.
   - `{{ENVIRONMENT}}` will be swapped for the value of `environment` parameter.
   - `{{IMAGE_TAG}}` will be swapped for the core CircleCI environment variable `${CIRCLE_SHA1}`
   - The sed expression (if any) given by the `extra-interpolation` parameter like so: `sed -i <extra-interpolation> manifest.yaml`
4. Copies the argo application manifest template `./templates/argo-applications/manifest.yaml` to the argo application manifest `./<environment>/argo-applications/<service>.yaml`
5. Interpolates placeholders within the argo application manifest as:
   - `{{ENVIRONMENT}}` will be swapped for the value of `environment` parameter.
   - `{{SERVICE}}` will be swapped for the value of `service` parameter.
6. Pushes the changes to the gitops repo as the github user `<gitops-username>`.

From there, as long as the prerequisites below are configured properly, Argo should take over and pull the changes from `./<environment>/<service>/manifest.yaml`
and deploy them to your kubernetes cluster.

## Prerequisites

- The source project is configured in Argo such that Argo watches the `./<environment>/<service>` folder for updates to deploy.
- A deploy key with push rights to the gitops repo has been assigned under "Additional SSH keys" in this source project.
  - The host name should be "github.com".
  - The fingerprint of this deploy key is the one used as the value of the `gitops-ssh-key-fingerprint` parameter.

## Example

```yaml
orbs:
  oot-deploy: ovotech/oot-deploy@2.2.0

jobs:
  update-gitops-nonprod:
    executor: oot-deploy/aws
    steps:
      - oot-deploy/update-gitops:
          service: my-service
          environment: nonprod
          account: "1234567890"
          extra-interpolation: "s/{{MY_PLACEHOLDER}}/value1/g;s/{{MY_OTHER_PLACEHOLDER}}/value2/g"
          gitops-repo: git@github.com:ovotech/my-gitops.git
          gitops-ssh-key-fingerprint: "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
          gitops-username: my-bot
          gitops-email: my-bot@myco.co.uk
```
