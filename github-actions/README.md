# GitHub Actions CircleCI orb

This orb can be used to trigger a GitHub Actions workflow from CircleCI.
The workflow can be triggered and the process will wait until it has completed or it can trigger the workflow and not wait for a response.

## Pre-requisites

In order to trigger a GitHub Action workflow it will require a token so that it can authenticate successfully.

**Note** that the token must be a project API token and not a personal API token.

## Commands
### execute_workflow

This command will trigger the GitHub Actions workflow.  It can then either wait until that workflow completes or just trigger it.

**Parameters**

- `github_action_token` - The GitHub Actions token to trigger the workflow.
- `repo_name` - The GitHub repository where the workflow can be found.
- `workflow_id` - The GitHub workflow filename.
- `git_branch` - The Git branch that the triggered workflow will use. 
- `workflow_parameters` - Double quoted key value pair of any extra parameters that the workflow requires.
- `wait_for_completion` - Defaults to false but if set to `true` it will wait for the workflow to complete.
- `timeout` - (in minutes).  This defaults to 10 minutes but can be increased if the workflow being triggered takes longer to complete.  This is only used when `what_for_completion` is set to `true`.

## Examples

### Trigger GitHub Action workflow.

```yaml
description: >
  Trigger a GitHub Actions pipeline (but do not wait for it to complete).

usage:
  version: 2.1
  orbs:
    github-actions: ovotech/github-actions@1.0.0
  workflows:
    gha-workflow:
      jobs:
        - github-actions/execute_workflow:
            github_action_token: $GHA_API_TOKEN
            repo_name: team-cppe
            workflow_id: trigger-circle.yml
            git_branch: main

```

### Trigger GitHub Action workflow and wait for completion.

```yaml
description: >
  Trigger a GitHub Actions pipeline and wait for it to complete.

usage:
  version: 2.1
  orbs:
    github-actions: ovotech/github-actions@1.0.0
  workflows:
    gha-workflow:
      jobs:
        - github-actions/execute_workflow:
            github_action_token: $GHA_API_TOKEN
            repo_name: team-cppe
            workflow_id: trigger-circle.yml
            git_branch: main
            wait_for_completion: true
```


### Download an artifact from a GitHub Actions Workflow

```yaml
description: >
  Downloads an artifact from a GitHub Actions Workflow

usage:
  version: 2.1
  orbs:
    github-actions: ovotech/github-actions@1.0.0
  workflows:
    gha-workflow:
      jobs:
        - github-actions/extract_artifact:
            github_action_token: $GHA_API_TOKEN
            repo_name: team-cppe
            artifact_name: test-artifact
```
