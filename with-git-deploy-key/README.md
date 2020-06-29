# Selecting specific SSH key when invoking Git

Sometimes you need to execute git operations on another private repository. 
When accessing github over SSH, git uses first available key, which is usually the key
for your "main" repository, and that key is a [Github deploy key](https://developer.github.com/v3/guides/managing-deploy-keys/).
This key is accepted by SSH, so SSH stops trying other keys found in ssh-agent, but rejected by Github auth
as not having sufficient permissions for another repository.

This orb provides a command, which configures Git to use specific
key found in ssh-agent. Key is identified by a fingerprint and needs to be
present in the agent already. On a CircleCI you can add more keys to the ssh-agent
by creating aditional SSH keys in the project settings.


## Example

Prepare key, add it to Github and CircleCI:

 1. Create an ssh key in pem format: `ssh-keygen -t ecdsa -m pem newkey`
 2. Add `newkey.pub` to the Github project you plan to access from CircleCI job
 3. Go to CircleCI project settings -> SSH keys ->  Additional SSH Keys -> Add SSH Key.
    Use empty hostname when prompted.
 4. Take a note of a key fingerprint, it will be used to identify this key later.


Use this Orb to invoke git commands using this key:

```yaml
version: 2.1
orbs:
  with-git-deploy-key: ovotech/with-git-deploy-key@1
jobs:
  gitops_image_update:
    parameters:
      image: {type: string}
    steps:
    - with-git-deploy-key/do:
        # Use fingerprint from CircleCI UI here
        ssh_key_fingerprint: "80:96:c0:86:7f:4f:7f:07:31:0d:69:bb:fb:14:90:3d"
        git_steps:
          - run: git clone git@github.com:myorg/gitops.git gitops
          - run:
              name: "Gitops: update image"
              command: |
                cd gitops
                #
                # Update image here, for instance 'kustomize edit set image << parameters.image >>'
                #
                git commit -m "CircleCI deploy ${CIRCLE_PROJECT_REPONAME}" -m  "Build URL: ${CIRCLE_BUILD_URL}" -a
                git push
```