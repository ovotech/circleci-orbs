# Gitops Deploy ORB

This orb provides a CircleCI job to commit image changes to your Helm manifests.

This orb will commit the `image_tag` at the specfied yaml path (`image_tag_yaml_path`), in the given yaml file (`values_file`) on the given GitHub branch (`manifest_branch`).

Optionally you can tag that commit with `commit_tag_name` to give ArgoCD a stable reference to sync with.

## Initial set-up

Since this orb commits changes to the target Git repository (by default the repository checked out by CircleCI) it requires write-access to that repository. By default CircleCI has read-only access.

### Create read-write deployment key

#### Create a private/public key pair:

```
ssh-keygen -t rsa -f /tmp/deploykey -N '' -q 1>/dev/null
```

This will create a `/tmp/deploykey` and `/tmp/deploykey.pub`

#### Configure GitHub with public key

**Using GitHub UI**
 - On the repository with your manifests, go to *Settings > Deploy Keys*.
 - Click *Add deploy key*
 - Give it an informative name (e.g. *CircleCI Gitops Deploy Key*)
 - Add the content of `/tmp/deploykey.pub` as the *Key*
 - Check *Allow write access*
  
**Using GitHub API**

Replace `<repo>` and `<github-access-token>` with the appropriate values.

```
curl -H"Authorization: token <github-access-token>"\
  --data @- https://api.github.com/repos/ovotech/<repo>/keys << EOF
{
        "title" : "CircleCI Gitops Deploy Key",
        "key" : "$(cat /tmp/deploykey.pub)",
        "read_only" : false
}
EOF
```

#### Configure CircleCI with private key

**Using CircleCI UI**

 - In the CircleCI project, go to *Project Settings > SSH Keys*
 - Under *Additional SSH Keys*, click *Add SSH Key*
 - Enter `github.com` for *hostname*
 - Enter the content of `/tmp/deploykey` for *Private Key*
 - Take a note of the **fingerprint**. You will need this later.
  
**Using CircleCI API**

Replace `<repo>` and `<circleci-access-token>` with the appropriate values.

```
PRIVATEKEY=$(cat /tmp/deploykey)
curl -X POST \
--header "Content-Type: application/json" \
-H "Circle-Token: <circleci-access-token>" \
-d "{\"hostname\":\"github.com\",\"private_key\":\"$PRIVATEKEY\"}" \
"https://circleci.com/api/v1.1/project/github/ovotech/<repo>/ssh-key" \
2>/dev/null
```
Take a note of the **fingerprint**. You will need this later.


## Usage

The orb assumes that your manifests have values files of the form `values-<environment>-<region>.yaml`

```
orbs:
  gitops: ovotech/gitops@0.1.0

workflows:
  cd:
    jobs:
      ...
      gitops/update-helm:
        name: gitops-deploy-sandbox-eu1
        environment: sandbox
        region: eu1
        image_tag_yaml_path: .backend.application.image.tag
        image_tag: $CIRCLE_SHA1
        values_file: manifests/values-sandbox-eu1.yaml # This is the default value for the given environment & region params
        manifest_branch: $CIRCLE_BRANCH
        commit_tag_name: sandbox-eu1
        ssh_key_fingerprint: <fingerprint>
        requires:
          ...
...
```

## Parameters

| Parameter | Type | Description | Default |
|---|---|---|---|
| `values_file` | string, optional | Path to your application's value file | `"manifests/values-{{environment}}-{{region}}.yaml"` |
| `manifest_branch` | string, required | The branch to commit the manifest changes to. Use `$CIRCLE_BRANCH` to use the current branch. | "master" |
| `image_tag_yaml_path` | string, required | The YAML path to the image to update. e.g. `.backend.application.image.tag` |  |
| `image_tag` | string, required | The value of the image | "master" |
| `environment` | string, required | E.g. prod, nonprod or uat |  |
| `region` | string, required | E.g. eu1 or ap1. |  |
| `ssh_key_fingerprint` | string, required | Fingerprint of the read-write SSH private key uploaded to CircleCI. See set-up. |  |
| `commit_tag_name` | string | If provided, forcibly tags the commit with the specified tag | "" |
| `git_email` | string | Email to use for commits to the manifest | "" |
| `git_email` | string | Name to use for commits to the manifest | "CircleCI Gitops Orb" |
| `argocd_url` | string | URL for ArgoCD. If provided (with `argocd_token`). Will poll ArgoCD and wait until its in sync. |  |
| `argocd_token` | string | API Token for ArgoCD. See https://github.com/ovotech/circleci-orbs/tree/master/argocdfor details. Required only if you want CircleCI to wait for ArgoCD to be in sync. |  |
| `yq_version` | string | Version of `yq` used to update the helm chart | "v4.6.2" |