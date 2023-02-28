# JIRA orb

This orb can be used to create an issue on the JIRA board based on a desired event triggered in the CircleCI pipeline job. For example previously when a CircleCI pipeline fails due to any critical or high vulnerability highlighted during the Snyk scan, the team had to manually create a ticket on the JIRA board to track the vulnerability.
This orb aims to automate the issue creation based on the the different inputs provided to the orb.

## Pre-requisites

In order to create the issue on the JIRA board, you need to add 2 environment variables to the project which holds a ['JIRA_API_TOKEN](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/) and 'JIRA_USER_EMAIL_ID'. Without these environment variable set in the project, this orb will not be able to successfully do its job.

**Note** that the token must be a project API token and not a personal API token.

## Commands
### create_issue

This command makes use of a wrapper shell script to communicate with the JIRA API to create an issue based on the the different inputs provided to the orb.

**Parameters**

- `user_email_id` - The user email id of the account using which the api_token is configured.
- `api_token` - The JIRA API token.
- `project_key` - The project key of the board where the issue is being created. e.g. "CPPE".
- `unique_id` - (Optional) This is the label for the issue being created. Make sure it's value is unique for each issue. If the unique_id with the same value already exists the orb will not create a new issue. e.g. "snyk-vulnerability-high-XSS-smartbookings"
- `issue_summary` - The summary of the issue being created.
- `issue_content` - The content of the issue being created.
- `priority` - (Optional) The priority of the issue being created. e.g. "Blocker". if you are passing this parameter then make sure to choose the issue_type which has priority attribute available.
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
            project_key: 'CPPE'
            priority: 'Blocker'
            issue_type: 'Engagement'
            label: 'snyk-vulnerability-high-XSS-smartbookings'
            issue_summary: 'Snyk vulnerability - Critical'
            issue_content: 'Snyk vulnerability - Critical'
```
