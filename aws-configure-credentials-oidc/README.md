# AWS Configure Credentials via OIDC

CircleCI provides a OpenID Connect (OIDC) ID token to any job with a context via the environment variable `CIRCLE_OIDC_TOKEN`.

This orb uses that token to assume the specified role in an AWS account; removing the need to keep and rotate AWS access keys in CircleCI contexts.

## How it works

1. You set up CircleCI as an identity provider in your AWS account. This tells IAM to trust the identity claims of the identity tokens issued by that provider, and the thumbprint allows AWS to verify the validity of the token. 
2. You create a role to be used to deploy your resources (this replaces the IAM User whose credentials would be stored in CircleCI). This role has a trust policy assigned to it, that means it can only be assumed by a particular project in a particular organisation. 
3. Use this orb to swap the `CIRCLE_OIDC_TOKEN` for temporary session credentials. These are then useable in subsequent steps in the job. **Note:** These will be ignored if your context has `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

## Set-up

First you'll need to create the CircleCI identity provider, an IAM role, a trust policy for that role, and assign any permissions required by your CircleCI workflow.

You will need to replace the `circleci_project_id` with the UUID of your CircleCI project (displayed in your project settings)

```
locals {
  circleci_org_id     = "4084b6f4-425d-43c6-996f-cce16b485731"
  circleci_project_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  // See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html#
  circleci_thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"  
}

resource "aws_iam_openid_connect_provider" "cluster_oidc_provider" {
  client_id_list  = [local.circleci_org_id]
  thumbprint_list = [local.circleci_thumbprint]
  url             = "https://oidc.circleci.com/org/${local.circleci_org_id}"
}

resource "aws_iam_role" "circleci" {
  name               = "CircleCI"
  description        = "Role used by CircleCI"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json 
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.circleci.com/org/${local.circleci_org_id}"]
    }
    condition {
      test     = "StringLike"
      variable = "oidc.circleci.com/org/${local.circleci_org_id}:sub"
      values   = [
        "org/${local.circleci_org_id}/project/${local.circleci_project_id}/user/*"
      ]
    }
  }
}
```

Take a note of the IAM Role arn above (in the above example it will be of the form `arn:aws:iam::999999999999:role/CircleCI`).

Lastly attach any required policies to your Role. 
```
resource "aws_iam_role_policy_attachment" "attach_policy_to_circleci" {
  role       = aws_iam_role.circleci.name
  policy_arn = "..."
}
```

## Usage

```
orbs:
  aws-configure-credentials-oidc: ovotech/aws-configure-credentials-oidc@0.1.0

jobs:
  ...
  tf-plan:
     ...
     steps:
        - aws-configure-credentials-oidc/aws-configure-credentials:
            role-arn: arn:aws:iam::999999999999:role/CircleCI
        # any steps which require the AWS credentials...
        - terraform/plan:
           ...
...

