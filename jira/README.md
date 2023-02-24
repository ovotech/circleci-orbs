# JIRA orb

This orb be used to create an issue on the JIRA board based on an event triggered in the CircleCI pipeline job. For example previously when a CircleCI pipeline fails due to any critical or high vulnerability highlighted during the Snyk scan, the team had to manually create a ticket on the JIRA board to track the vulnerability.
This orb aims to automate the issue creation based on the desired type and priority of the incident defined as inputs to the orb.

## Pre-requisites
In order to create the issue on the JIRA board, you need to add an environment variable to the project which holds a [JIRA API token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/). Without this environment variable set, this orb will not be able to successfully create the issue.

**Note** that the token must be a project API token and not a personal API token.

## Commands
### create_issue

This is the only command that exists within this orb at the moment and makes use of a wrapper shell script to communicate with the JIRA API to create an issue based on what you've passed into the command parameters.

**Parameters**
- `user_email_id` - Environment variable containing the user email id of the account using which the api_token is configured.
- `api_token` - Environment variable containing JIRA API token. If not set, the orb will not be able to communicate with JIRA.
- `project_key` - This is the key for the board on which you want to create the issue e.g. "CPPE"
- `label` - This is the label for the issue being created. Make sure that this label for each ticket. If the label with the same name already exists the orb will not create a new issue. e.g. "snyk-vulnerability-high-XSS-smartbookings"
- `issue_summary` - The summary of the issue being created.
- `issue_content` - The content of the issue being created.
- `priority` - The priority of the issue being created. e.g. "Blocker"
- `issue_type` - The type of the issue being created. e.g. "Engagement"

## Examples

### Create a new issue on the board
```yaml
description: >
  Create a JIRA issue on the selected project board

usage:
  version: 2.1
  orbs:
    jira: ovotech/jira@1.0.0
  workflows:
    jira-workflow:
      jobs:
        - jira/create_issue:
            api_token: JIRA_API_TOKEN
            project_key: "CPPE"
            priority: "Blocker"
            issue_type: "Engagement"
            label: "snyk-vulnerability-high-XSS-smartbookings"
            issue_summary: "Snyk vulnerability - Critical"
            issue_content: "Snyk vulnerability - Critical"
```