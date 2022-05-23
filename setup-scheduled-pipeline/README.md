# CircleCI Scheduled Trigger Creation orb

This orb is responsible for setting up schedules for [scheduled pipelines](https://circleci.com/docs/2.0/scheduled-pipelines/#get-started). Previously the only way to do this was via the [CircleCI API](https://circleci.com/docs/api/v2/) or via the UI. This orb aims to bring the maintainability aspect to these schedules by capturing the config natively within the CircleCI config.

## Commands
### create_scheduled_pipeline

This is the only command that exists within this orb and makes use of a wrapper shell script to communicate with the CircleCI API to create your desired schedule based on what you've passed into the command parameters.

**Parameters**
- `schedule_name` - Name of the schedule
- `schedule_description` - Description of the schedule
- `schedule_hour_frequency` - Number of times a schedule triggers per hour, value must be between 1 and 60
- `schedule_hours` - Comma separated hours in a day in which the schedule triggers
- `schedule_days` - Comma separated days in a week in which the schedule triggers
- `target_branch` - Branch on which the scheduled pipeline will trigger

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