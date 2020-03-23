# AWS CircleCI parameter store orb

This orb can be used to retrieve and rename paramaters from aws parameter store.

## Commands
### get-parameters
This is the only command available in this orb. It gets a list of parameters from aws, renames them and saves them to the given file.

**Parameters**
- `output-file` - output file to write the parameters to - is then used with the ```source ENVIRONMENT_STORE_FILE``` command
- `values` - list of values to download from the parameter store. These are separated with an equals to the variable they will be assigned to eg ```/environment=TF_VAR_environment```
- `aws-access-key-id` - (optional) name of the CircleCI environment variable which holds a value of the aws access key id. (defaults to `AWS_ACCESS_KEY_ID`)
- `aws-secret-access-key` - (optional) name of the CircleCI environment variable which holds a value of the aws secret access key (defaults to `AWS_SECRET_ACCESS_KEY`)
- `profile-name` - (optional) profile name to be configured. (defaults to `default`)
- `aws-region` - (optional) env var of AWS region to operate in (defaults to `AWS_DEFAULT_REGION`)

## Examples
Make sure you have the following environment variables set up in CircleCI:
- AWS access key id, secret access key and AWS region, e.g. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION`. Your environment variables can have any name you want as long as you configure the aws cli and correctly reference the names in the orb parameters (see the examples below).

The following example has the following CircleCI env vars `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_DEFAULT_REGION` so they are automatically picked up by aws cli.

```yaml
version: 2.1

orbs:
  aws-get-parameters: ovotech/aws-get-parameters@1
executors:
    kotlin:
        docker:
            - image: circleci/openjdk:8

jobs:
  load-parameters:
    executor: kotlin
    steps:
        - attach_workspace:
              at: ~/working
        - aws-get-parameters:
              output-file: ENVIRONMENT_STORE_FILE
              values: >-
                  /aiven/clusterUrl=KAFKA_CLUSTER_URL \
                  /aiven/schemaUrl=KAFKA_SCHEMA_URL \
                  /aiven/truststoreJks=KAFKA_TRUST_STORE \
                  /aiven/keystoreJks=KAFKA_KEY_STORE \
                  /aiven/javaPass=KAFKA_KEY_PASSWORD \
                  /aiven/serviceUsername=KAFKA_SCHEMA_USER \
                  /aiven/servicePassword=KAFKA_SCHEMA_PASSWORD
        - run:
              name: Add circle ci environment variables
              command: |
                  echo "export TF_VAR_project_name=$CIRCLE_PROJECT_REPONAME" >> ENVIRONMENT_STORE_FILE
                  echo "export VERSION=${CIRCLE_TAG:-$CIRCLE_BRANCH-$CIRCLE_BUILD_NUM}" >> ENVIRONMENT_STORE_FILE
        - persist_to_workspace:
              root: .
              paths:
                  - ENVIRONMENT_STORE_FILE
    use-parameters:
        executor: kotlin
        working_directory: ~/working
        steps:
            - attach_workspace:
                  at: ~/working
            - run:
                  name: Login to aws
                  command: |
                      source ENVIRONMENT_STORE_FILE
                      use environmetal variables

workflows:
    version: 2.1
    smint-flow-xml-producer:
        jobs:
            - checkout-code:
                   filters:
                       tags:
                           only: /^\d+\.\d+\.\d+$/
            - import-parameters:
                  name: import-parameters-nonprod
                  context: smint-nonprod
                  requires:
                      - checkout-code
```

The following job uses the following CircleCI env variables `PROD_AWS_ACCESS_KEY_ID` and `PROD_AWS_SECRET_ACCESS_KEY` which are not automatically picked up by aws cli and therefore you need to set up the credentials manually.

```yaml
version: 2.1

jobs:
  load-parameters:
    executor: kotlin
    steps:
        - attach_workspace:
              at: ~/working
        - aws-get-parameters:
              output-file: ENVIRONMENT_STORE_FILE
              values: /aiven/clusterUrl=KAFKA_CLUSTER_URL
              aws-access-key-id: $PROD_AWS_ACCESS_KEY_ID
              aws-secret-access-key: $PROD_AWS_SECRET_ACCESS_KEY
              aws-region: eu-west-1
```
