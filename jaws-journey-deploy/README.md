# Smart Journeys (JAWS) Standard CircleCI Deployment

This orb provides a standard deployment process for all journey repositories to ensure common code between them.

## Commands

### checkout-code
This circleci step checks out your repositories code, and persists it to a working directory
**Parameters**
Does not require any parameters to be provided
**Example**
The following snippet shows you what you need to set as your job to implement this step
```yaml
orbs:
  deploy-orb: ovotech/jaws-journey-deploy@1.0.0

jobs:
  - deploy-orb/checkout-code:
      <<: *any-cd-pipeline
```
### avro
This step performs two functions for the journey code bases.  Firstly it checks whether the version of the schema that the code would produce is compatible with the version of the schema currently in Aiven, and it uploads the schema to Aiven's schema registry

**Parameters**

`uploadschema` - boolean value expected, which indicates whether you want to run the upload avro step.  Default value is false

`environment` - indicates to the build step which properties file to run against.  Expected values are [sandbox, nonprod, prod]

**Example**

Below shows if you want to run the compatibility check and upload the avro schema
```yaml
- deploy-orb/avro:
    <<: *deploy-sandbox
    name: avro-cd-sandbox
    environment: sandbox
    uploadschema: true
```
### build-and-test

**Parameters**
`subproject` - which service within the repo are you wanting to build

`environment` - indicates to the build step which properties file to run against.  Expected values are [sandbox, nonprod, prod]

`publish` - indicates whether you want to upload the resulting Docker image to AWS ECR

**Example**

The example below shows how to run the build and run unit tests steps as well as publishing the image to AWS ECR
```yaml
- deploy-orb/build-and-test:
    name: build-and-test-publish-<< matrix.subproject >>
    environment: sandbox
    matrix:
      alias:
        build-and-test-publish-sandbox
      <<: *all-services-matrix
    <<: *deploy-sandbox
    publish: true
```
### integration-test

**Parameters**

**Example**
```yaml
- deploy-orb/integration-test:
    name: integration-test-<< matrix.subproject >>
    environment: sandbox
    matrix:
      alias:
        integration-test
      <<: *integration-test-services-matrix
    <<: *ci-build
```
### synk-scan

Performs a check to make sure your code dependencies do not introduce any new security vulnerabilities 

**Parameters**

Does not require any parameters passed through.  However it does require that you provide a SNYK_TOKEN within the project environment variables or context

**Example**
```yaml
  - deploy-orb/snyk-scan:
      name: snyk-scan
      <<: *ci-build
```
### tf-plan

**Parameters**

**Example**
```yaml
- deploy-orb/tf-plan:
    <<: *ci-build
    name: tf-plan-<< matrix.path >>-<< matrix.environment >>
      matrix:
        parameters:
          path:
            - main
            - kubernetes
          environment:
            - sandbox
```
### tf-apply

**Parameters**

**Example**
```yaml
- deploy-orb/tf-apply:
    <<: *prod-job
    name: tf-apply-<< matrix.path >>-<< matrix.environment >>
    matrix:
    parameters:
      path:
        - main
      environment:
        - prod
```
### run-automation-test

**Parameters**

`environment` - indicates to the build step which properties file to run against.  Expected values are [sandbox, nonprod, prod]

**Example**
```yaml
- deploy-orb/run-automation-test:
    <<: *deploy-sandbox
    name: run-automation-test
    parameters:
      environment: sandbox
```
### notify-shipit
**Parameters**

Does not require any parameters passed through.  However it does require that you provide a SHIPIT_API_KEY within the project environment variables or context

**Example**
```yaml
- deploy-orb/notify-shipit:
    <<: *prod-job
    requires:
      - tf-apply-kubernetes-prod
```