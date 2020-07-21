# Get Current Environment

The environment that we want to deploy to is dependent on the current branch or tag that we are deploying. 
For example, we wish to deploy all tags to prod, the master branch to nonprod and all other branches to sandbox.

This orb takes in the current git tag and branch and writes the correct environment to the $BASH_ENV file

## Commands
### set-env
This is the only command available in this orb. It gets the current environment and sets it to the $BASH_ENV file

**Parameters**

|Parameter Name| Optional |Default|Description|
|--------------|----------|-------|-----------|
|git-branch|No|-|Name of the current git branch - set this to `pipeline.git.branch` which can not be accessed in orb scope|
|git-tag   |No|-|Name of the current git tag - set this to `pipeline.git.tag`|
|main-branch-name|Yes|master|Name of the branch to consider the "main" branch|
|env-name-tag|Yes|prod|Value to set environmental variable to if branch matches test for tag (git-tag is not empty)|
|env-name-main-branch|Yes|nonprod|Value to set environmental variable to if branch matches test for main-branch (git-branch is main-branch-name)|
|env-name-other-branch|Yes|sandbox|Value to set environmental variable to if branch matches test for main-branch (git-tag empty and git-branch not main-branch-name)|
|environment-variable|Yes|ENVIRONMENT|Name of environmental variable to set to branch specific value|

## Examples

###Only git branch and tag set

```yaml
version: 2.1

orbs:
  env-orb: ovotech/set-current-environment@1

jobs:
  set-environment:
    executor: any
    steps:
    - env-orb/set-env:
         git-branch: << pipeline.git.branch >>
         git-tag: << pipeline.git.tag >>

workflows:
  test:
    jobs:
      - set-environment
```

###All variables set
The master branch is called main. The environmental variable to be set is PROFILE rather than ENVIRONMENT.The variable 
for tags is tag-name, the main branch is main-name and for other branches is other-name.

```yaml
version: 2.1

orbs:
  env-orb: ovotech/set-current-environment@1

jobs:
  set-environment:
    executor: any
    steps:
    - env-orb/set-env:
         git-branch: << pipeline.git.branch >>
         git-tag: << pipeline.git.tag >>
         main-branch-name: main
         env-name-tag: tag-name
         env-name-main-branch: main-name
         env-name-other-branch: other-name
         environment-variable: PROFILE

workflows:
  test:
    jobs:
      - set-environment
```
