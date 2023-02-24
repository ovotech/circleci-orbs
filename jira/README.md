# JIRA orb

This orb be used to create an issue on the JIRA board when any desired event happends in the CircleCI pipeline. For example previously when a CircleCI pipeline fails due to any critical or high vulnerability highlighted during the Snyk scan, the team had to manually create a ticket on the JIRA board to track the vulnerability.
This orb aims to automate the issue creation based on the desired type and priority of the incident defined as inputs to the orb.

## Pre-requisites

The intention of the orb is that it will be called from within the repository / project for which the schedule is to be created. Creating schedules for other repositories is not currently supported.

In order to create the issue on the JIRA board, you need to add a [CircleCI environment variable](https://circleci.com/docs/2.0/env-vars/) to the project which holds a [JIRA API token](https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/). Without this environment variable set, this orb will not be able to successfully create the issue.

**Note** that the token must be a project API token and not a personal API token.

## Commands
### create_issue

This is the only command that exists within this orb at the moment and makes use of a wrapper shell script to communicate with the CircleCI API to create your desired schedule based on what you've passed into the command parameters. This command is also wrapped within a job with the same name `create_scheduled_pipeline`.

**Parameters**
- `schedule_name` - Name of the schedule
- `schedule_description` - Description of the schedule
- `schedule_hour_frequency` - Number of times a schedule triggers per hour, value must be between 1 and 60
- `schedule_hours` - Comma separated hours in a day in which the schedule triggers
- `schedule_days` - Comma separated days in a week in which the schedule triggers
- `target_branch` - Branch on which the scheduled pipeline will trigger
- `circleci_token` - Environment variable containing CircleCI personal API token. If not set, will try and look for 
- `config_path` - Path of the scheduled scan config yml file

## Examples

### Simple schedule for scheduled pipeline that runs weekly on Monday morning
```yaml
description: >
  Sample usage of the setup scheduled pipeline setup orb.

usage:
  version: 2.1
  orbs:
    setup-scheduled-pipeline: ovotech/setup-scheduled-pipeline@1.0.0
  workflows:
    example-workflow:
      jobs:
        - setup-scheduled-pipeline/create_scheduled_pipeline:
            schedule_name: '<REPO_NAME>-weekly-workflow'
            schedule_description: 'A weekly workflow on the main branch that executes once at 9 am every Monday'
            schedule_hour_frequency: '1'
            schedule_hours: '9'
            schedule_days: 'MON'
            target_branch: 'main'
            circleci_token: SERVICE_USER_CIRCLECI_TOKEN
            config_path: "circleci/scheduled_scan_config.yml"
```

## Consuming the schedule and adding workflow filtering

As a scheduled pipeline is essentially a triggered pipeline, by default it will run every workflow in the config.

To prevent this behaviour you can run workflows conditionally based on the pipeline values which will specify whether the pipeline is triggered by a desired schedule. For example:
```yaml

weekly-run-workflow:
  when:
    and:
      - equal: [ scheduled_pipeline, << pipeline.trigger_source >> ]
      - equal: [ "<REPO_NAME>-weekly-workflow", << pipeline.schedule.name >> ]
  jobs:
    - test
    - build
    - deploy
```

For more details, please check out the [official documentation](https://circleci.com/docs/2.0/scheduled-pipelines/#workflows-filtering)