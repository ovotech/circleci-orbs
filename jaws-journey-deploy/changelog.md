# 3.3.5
* Default lib-build-and-test and integration-test jobs to using ubuntu-2004:current instead of an older 20.04 image that's no longer available

# 3.3.0
* Update node to 20.11.0 to allow semantic release to work create-release

# 3.2.0
* Add snykProject parameter to snyk-scan command and job

# 3.1.0
* Update node to 20.6.1 to allow semantic release to work create-release

# 3.0.1
* Bump Snyk orb version to get retries for the Snyk CLI download step

# 3.0.0
* Using circleci ip's for avro job to enable connectivity to our aiven clusters
* OIDC used in avro job
### Breaking change
* The OIDC parameter now defaults to true for all jobs that previously used access keys EXCEPT publish-image-kmi. This will break pipelines that use contexts without CIRCLE_IAM_ROLE_ARN declared, unless they set the parameter to `false` on calls to the orb.

# 2.7.0
* Add snykPolicyPath parameter to build_and_test, publish-image & build-and-test

# 2.6.0
* Update automation test step to use circleci ip ranges

# 2.5.0
* FIX to command: publish-image-kmi, it was missed out on when aws-ecr orb version was changed

# 2.4.0
* Update snyk docker image scan to exclude app vulnerabilities

# 2.3.0
* Node upgrade from 14.17.3 to 19.3.0 as semantic-release requires node version >=18

# 2.0.1
* using version 1.1.0 of the argocd orb, which allows making a sync request instead of waiting for sync to a target.
* new sync_request parameter for gitops-deploy, false by default

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
