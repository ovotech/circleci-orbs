# JIRA orb

This orb can an be used to interact with JIRA in a CI pipeline. This orb aims to automate the issue creation and issue query based on the the different inputs provided to the orb. At the moment this orb supports two commands. 

The 'create_issue' command can be used to create an issue on the JIRA board when a particular event is triggered in the CircleCI pipeline job. For example previously when a CircleCI pipeline fails due to any critical or high vulnerability highlighted during the Snyk scan, the team had to manually create a ticket on the JIRA board to track the vulnerability.

The 'query_issue' command can communicate with the JIRA API to query an issue based on the type of 'priority' provided as input to the orb. If a team wants to cancel a deployment in CircleCI by querying if a particular type of priority of an issue exists on the baord e.g. "Blocer".


## Pre-requisites

In order to create the issue on the JIRA board, you need to add 2 environment variables to the project which holds a ['JIRA_API_TOKEN](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/) and 'JIRA_USER_EMAIL_ID'. Without these environment variable set in the project, this orb will not be able to successfully do its job.

**Note** that the token must be a project API token and not a personal API token.

## Commands
### create_issue
This command makes use of a wrapper shell script to communicate with the JIRA API to create an issue based on the different inputs provided to the orb.

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

### query_issue
This command makes use of a wrapper shell script to communicate with the JIRA API to query an issue based on the type of 'priority' provided as input to the orb.

**Parameters**

- `user_email_id` - The user email id of the account using which the api_token is configured.
- `api_token` - The JIRA API token.
- `project_key` - The project key of the board where the issue is being created. e.g. "CPPE".
- `jql_query` - The jql query to run. e.g. "project = \"CPPE\" AND priority = \"Blocker\"".

## Examples

### Create a new issue on the board

```yaml
description: >
  Query JIRA board to check if any issues based on the type of 'priority'.

usage:
  version: 2.1
  orbs:
    jira: ovotech/jira@1
  workflows:
    jira-workflow:
      jobs:
        - jira/query_issue:
            user_email_id: $JIRA_USER_EMAIL_ID
            api_token: $JIRA_API_TOKEN
            project_key: CPPE
            jql_query: 'project = \"CPPE\" AND priority = \"Blocker\"'
```