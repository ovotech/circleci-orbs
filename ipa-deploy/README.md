# IPA Deploy Orb

This orb has a collection of commands and jobs that IPA use to deploy their services.

## Commands

### load_templates

This command exports and allows the use of a "SLACK_DEPLOY_FAILED_TEMPLATE" env var as the template
parameter for the slack orb's `notify` command.

### npm_ci

This command can be used to set up a npm token stored under environment variable `NPM_TOKEN` and then install npm dependencies. 

Parameters:
* `service-account` - The service account email address to rotate the key of
* `steps` - The series of steps to perform during key rotation
* `ssm-path` - The SSM path to save the updated key in

### notify-slack-on-failure

This command can be used to send a slack notification if a job fails

Parameters:
* `channel` - The slack chanel that a notification should be sent to
* `mentions` - Any slack handles that should be mentioned in the noticiation

### deploy-run-integration-tests

This command can be used to deploy a serverless stack and run integration tests on that stack.

Parameters:
* `executor` - The executor that the command should be ran on
* `stage` - The stage that the integration stack is being deployed to 
* `region` - The region that the integration stack is being deployed to

## Jobs

### checkout

This job is used to checkout git and save to workspace.

### eslint

This job is used to run eslint against the source code.

### jest-tests

This job is used to run the tests saved in the repo.

### deploy

This job deploys the serverless stack to an AWS account.

Parameters:
* `stage` - The stage that the serverless stack should be deployed with
* `region` - AWS region to deploy to
* `branch` - The git branch that the change was deployed from. Can be passed in using << pipeline.git.branch >>.

### delete-feature-branch-stack

This job can be used to delete the feature stack deployed from a git branch after the branch has been merged in.

Parameters:
* `region` - AWS region that the stack is being removed from

### delete-feature-branch-integration-stack

This job can be used to delete the feature stack deployed from a git branch, for integration tests, after the branch has been merged in.

Parameters:
* `region` - AWS region that the stack is being removed from


