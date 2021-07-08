# ASP Deploy Orb

Allows automatic deployments by providing two commands:

- `ecr-push` - Pushes an image to your own ECR
- `update-gitops` - Updates a specified gitops repo with the latest service image tag.

## Prerequisites

K8s cluster to be configured with Argo and Kustomize and your gitops repo to be in the following structure:

```
- nonprod:
  - service-a:
      deployment.yaml # Specific configuration for this service
  - service-b:
      deployment.yaml
  kustomization.yaml # This file is updated in every deploy and contains the image names, tags and file paths
- prod:
  - service-a:
      deployment.yaml
  - service-b:
      deployment.yaml
  kustomization.yaml
```

Check the [ASP Team's Gitops repo](https://github.com/ovotech/asp-gitops) for an example.

## Parameters - `ecr-push`

| Parameter             | Required |                          Default                           | Description                                           |
| --------------------- | :------: | :--------------------------------------------------------: | ----------------------------------------------------- |
| env                   |   Yes    |                             -                              | Which env to deploy within                            |
| service-name          |    No    |                `${CIRCLE_PROJECT_REPONAME}`                | Service name used when pushing to ECR repo            |
| image-name            |    No    | `${CIRCLE_PROJECT_REPONAME}:$(git rev-parse --short HEAD)` | Name of the image to be pushed to ECR                 |
| image-tag             |    No    |                  `$(git describe --tags)`                  | Git tag of the service to be deployed                 |
| aws-account-url       |   Yes    |                             -                              | URL for the ECR AWS Account used to push the image to |
| aws-access-key-id     |   Yes    |                             -                              | Key ID for the ECR AWS Account                        |
| aws-secret-access-key |   Yes    |                             -                              | Access Key for the ECR AWS Account                    |

## Parameters - `update-gitops`

| Parameter            | Required |           Default            | Description                                              |
| -------------------- | :------: | :--------------------------: | -------------------------------------------------------- |
| env                  |   Yes    |              -               | Which env to deploy within                               |
| service-name         |    No    | `${CIRCLE_PROJECT_REPONAME}` | Service name used in updating kubernetes manifests       |
| image-tag            |    No    |   `$(git describe --tags)`   | Git tag of the service to be deployed                    |
| gitops-repo          |   Yes    |              -               | HTTPS URL for repository containing kubernetes manifests |
| gitops-deploy-branch |    No    |            `main`            | Gitops repository branch to make changes to              |
| gitops-username      |   Yes    |              -               | Username to associate with git actions                   |
| gitops-email         |   Yes    |              -               | Email to associate with git actions                      |
| aws-account-url      |   Yes    |              -               | Registry URL used to update the kubernetes manifest      |

## Example Usage

```yaml
orbs:
  asp-deploy: ovotech/asp-deploy@1.0.0

jobs:
  deploy-to-uat:
    docker:
      - image: cimg/base:stable
    steps:
      - migrate
    - asp-deploy/ecr-push:
        env: nonprod
        aws-account-url: AWS_ECR_ACCOUNT_URL_NONPROD
        aws-access-key-id: AWS_ACCESS_KEY_ID_NONPROD
        aws-secret-access-key: AWS_SECRET_ACCESS_KEY_NONPROD
        service-name : CUSTOM_SERVICE_NAME # default is ${CIRCLE_PROJECT_REPONAME}
        image-name: CUSTOM_IMAGE_NAME # default is ${CIRCLE_PROJECT_REPONAME}:$(git rev-parse --short HEAD)
    - asp-deploy/update-gitops:
        env: nonprod
        service-name : CUSTOM_SERVICE_NAME # default is ${CIRCLE_PROJECT_REPONAME}
        image-name: CUSTOM_IMAGE_NAME # default is ${CIRCLE_PROJECT_REPONAME}:$(git rev-parse --short HEAD)
        aws-account-url: AWS_ECR_ACCOUNT_URL_NONPROD
        gitops-repo: YOUR_GITOPS_REPO_HTTPS_URL
        gitops-deploy-branch: YOUR_GITOPS_REPO_BRANCH # default is "main"
        gitops-username: YOUR_GITHUB_BOT_USERNAME
        gitops-email: YOUR_GITHUB_BOT_EMAIL

```
