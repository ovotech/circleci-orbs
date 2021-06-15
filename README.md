[![CircleCI](https://circleci.com/gh/ovotech/circleci-orbs.svg?style=shield&circle-token=ae0a459eabe5a6b454eab8e241a516fd1a212e8c)](https://app.circleci.com/pipelines/github/ovotech/circleci-orbs)

# CircleCI Orbs

This repo contains public circleci orbs in the ovotech namespace.

## Contributing

Orbs follow the conventions:

* **Directory** named the **same** as the orb

* A single Dockerfile in the executor directory (unless you specify publish-docker-image:false)

* The orb yaml is in a file name `orb.yml`

* Published in the ovotech namespace

* An `orb_version.txt` file may exist in an orb directory containing the version of the orb. (A new version is only published when the version changes)

* An entry in [CODEOWNERS](./.github/CODEOWNERS) indicating which team maintains the orb - they will be responsible for reviewing
any changes to the orb.

* The orb will need to be added to the list published by Circle at the bottom of the [Circle config](./.circleci/config.yml)

## Published Orbs

 - [ovotech/argocd](argocd) - Interact with an ArgoCD API.
 - [ovotech/aws-get-parameters@1](aws-get-parameters) - Get parameters from AWS Parameter Store.
 - [ovotech/aws-rotate-keys@1](aws-rotate-keys) - Rotate AWS access keys and update corresponding CircleCI environment variables.
 - [ovotech/clair-scanner@1](clair-scanner) - Scan Docker images for vulnerabilities.
 - [ovotech/rac-gcp-deply@1](rac-gcp-deploy) - Deploy Scala services to a Kubernetes cluster running in Google Cloud.
 - [ovotech/set-current-environment@1](set-current-environment) - Set current environment (master branch, tag or other) to environmental variable.
 - [ovotech/terraform@1](terraform) - Plan and apply Terraform modules, with terraform <=0.14
 - [ovotech/terraform-v2@2](terraform-v2) - Plan and apply Terraform modules, with terraform >=0.14
 - [ovotech/tools-install@1](tools-install) - Download and unpack tools archives
 - [ovotech/with-git-deploy-key@1](with-git-deploy-key) - Execute Git operations on another repo selecting specific public key.
 - [ovotech/clojure](clojure) - test, scan and package Clojure projects built using Leiningen. 
 - [ovotech/oot-eks](oot-eks) - deploy services to EKS, OOT-style. 
 - [ovotech/oot-deploy](oot-deploy) - deploy services via Argo, OOT-style. 
 - [ovotech/sbt-deploy](sbt-deploy) - Deploy services via Argo, using Kustomize. 
 - [ovotech/jaws-journey-deploy](sbt-deploy) - Provides a standard deployment process for all jaws journey repositories.
 - [ovotech/pipeline-utils](pipeline-utils) - Miscellaneous bash commands to ease CircleCI pipeline development.

 Other orbs in the ovotech namespace:
 - [ovotech/shipit@1](https://github.com/ovotech/pe-orbs/tree/master/shipit) - Run shipit and record deployments to https://shipit.ovotech.org.uk.
