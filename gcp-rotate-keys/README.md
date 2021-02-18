# GCP Rotate Keys Orb

This orb can be used to rotate the keys for GCP service accounts, performing
arbitrary processing after the new key is created but before the old key is
deleted. This is useful for performing actions such as restarting services to
pick up the new keys, etc.

## Executors

This orb defines a single default executor that is the `cimg/base:stable`
docker image. The orb commands require `bash`, `jq`, `aws`, and `gcloud` so any
image which contains those utilities will work.

## Commands

### rotate-gcp-key

This command rotates the key of the given GCP service account and performs
arbitrary processing after creating the new key but before deleting the old
one.

This command requires that authentication to `gcloud` has been performed. See
the [circleci/gcp-cli](https://circleci.com/developer/orbs/orb/circleci/gcp-cli)
orb for one way to handle authentication.

The command makes available three environment variables so that the processing
stage can do things with the keys:
* `GENERATED_KEY_PATH` - Path containing the exported JSON key file
* `GENERATED_KEY_ID` - ID of the key that has been created
* `PREVIOUS_KEY_ID` - ID of the key that is being rotated out

The JSON key file at `GENERATED_KEY_PATH` is deleted after this command finishes.

Parameters:
* `service-account` - The service account email address to rotate the key of
* `steps` - The series of steps to perform during key rotation

### rotate-gcp-key-in-aws-ssm

This command is almost identical to `rotate-gcp-key` however it will upload the
generated key to AWS SSM Parameter Store before performing arbitrary
processing.

As well as requiring that authentication to `gcloud` has been performed, this
command also requires that authentication to `aws` has been performed. See the
[circleci/aws-cli](https://circleci.com/developer/orbs/orb/circleci/aws-cli)
orb for one method to handle AWS authentication.

Parameters:
* `service-account` - The service account email address to rotate the key of
* `steps` - The series of steps to perform during key rotation
* `ssm-path` - The SSM path to save the updated key in

## Jobs

### rotate-key-redeploy-ecs-service

This job rotates the key of the given GCP service account, uploads the key to
AWS SSM Parameter Store, and finally forces a redeploy of an AWS ECS service.

Parameters:
* `aws-access-key-id` - AWS access key id for IAM role
* `aws-region` - AWS region to operate in
* `aws-secret-access-key` - AWS secret key for IAM role
* `ecs-cluster-name` - Name of the ECS cluster containing the service to
  redeploy during the key rotation process
* `ecs-service-name` - Name of the service to redeploy during the key rotation
  process
* `gcloud-service-key` - Full service key JSON file to connect with
* `google-compute-region` - The Google compute region to connect with
* `google-compute-zone` - The Google compute zone to connect with
* `google-project-id` - The Google project ID to connect with
* `redeploy-timeout` - Number of seconds to wait for the redeployment to reach
  steady state
* `service-account` - The service account email address to rotate the key of
* `ssm-path` - The SSM path where the service account key is saved

## Limitations

Currently the commands will abort without doing anything if the service account
has more than key.
