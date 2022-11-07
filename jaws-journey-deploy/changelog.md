# 2.0.1
* using version 1.1.0 of the argocd orb, which allows making a sync request instead of waiting for sync to a target. Doesn't by default

# 2.0.0

* aws-ecr orb changed from version `7.2.0` to `8.1.3`
* ovotech/aws-configure-credentials-oidc@1.0.1 added
* for build-pushes and terraform jobs, oidc is used instead of aws keys/secrets if the oidc parameter is set to true when using this orb

### Breaking change 
* `docker.pkg.github.com` must be changed to `ghcr.io` in dockerfiles that use images from our github container repository

### New environment variables used 
* CIRCLE_IAM_ROLE_ARN (optional)
* AWS_ACCOUNT_ID

### Deprecated environment variables 
* ACCOUNT_URL

### New parameters 
* oidc - boolean (optional, false by default)