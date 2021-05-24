# ArgoCD Deploy Orb

Interacts with an ArgoCD API (currently only provides ability to wait for ArgoCD to be in sync)

## Prerequisites

You will need to use a context with `ARGOCD_TOKEN` populated with a token from the project your application resides in. To generate a token, in ArgoCD UI got to *Projects* > *Your team name* > *Roles* > *read-only* and create a JWT token at the bottom. Give it a sensible ID, such as `circleci`. This token can be re-used amongst all applications in your team's project; it provides read-only access to your project and its application.


## Example Usage

### Wait for sync

The `target` must be the commmit hash you expect ArgoCD to sync with.

```yaml
orbs:
  argocd: ovotech/argocd@0.1.0

jobs:
  deploy-to-uat:
    context: jaws-nonprod # Must have ARGOCD_TOKEN in the context
    steps:
    - gitops-deploy # Deploys to manifest repo, persists as commit hash as ARGO_TARGET_REVISION in $BASH_ENV
    - argocd/wait_for_sync:
        application: journey-meter-tariff-extractor
        argocd_url: https://argocd.metering-shared-non-prod.ovotech.org.uk/
        target: $ARGO_TARGET_REVISION
    - run-test
```
