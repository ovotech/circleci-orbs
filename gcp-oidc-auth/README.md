# GCP Configure Credentials via OIDC

CircleCI provides a OpenID Connect (OIDC) ID token to any job with a context via the environment variable `CIRCLE_OIDC_TOKEN`.

This orb uses that token to assume the specified role in an GCP account; removing the need to keep and rotate GCP service account keys in CircleCI contexts.

## How it works

1. You set up CircleCI as an identity provider in your GCP project under workload identity provider. This tells IAM to trust the identity claims of the identity tokens issued by that provider, and the thumbprint allows GCP to verify the validity of the token. 
2. You create a role to be used to deploy your resources (this replaces the IAM User whose credentials would be stored in CircleCI).  
3. Use this orb to swap the `CIRCLE_OIDC_TOKEN` for temporary session credentials. These are then useable in subsequent steps in the job. **Note:** These will be ignored if your context has `GCP_APPLICATION_CREDENTIAL`

## Set-up

First you'll need to create the CircleCI identity provider, an IAM role, a trust policy for that role, and assign any permissions required by your CircleCI workflow.


