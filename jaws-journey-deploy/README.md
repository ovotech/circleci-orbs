# Smart Journeys (JAWS) Standard CircleCI Deployment

This orb provides a standard deployment process for all journey repositories to ensure common code between them.

### Steps

Available Steps
* [checkout-code](#checkout-code)
* [build-and-test](#build-and-test)
* [integration-test](#integration-test)
* [avro](#avro)
* [synk-scan](#synk-scan)
* [tf-plan](#tf-plan)
* [tf-apply](#tf-apply)
* [notify-shipit](#notify-shipit)
* [run-automation-test](#run-automation-test)

### checkout-code

**Description**

This circleci step checks out your repositories code, and persists it to a working directory

Parameters

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

**Description**

This step performs two functions for the journey code bases.  Firstly it checks whether the version of the schema that the code would produce is compatible with the version of the schema currently in Aiven, and it uploads the schema to Aiven's schema registry

**Parameters**

* uploadschema: Boolean value expected, which indicates whether you want to run the upload avro step.  Default value is false
* environment: Indicates to the build step which properties file to run against.  Expected values are `[sandbox, nonprod, prod]`

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

**Description**



**Parameters**

* serviceName: Which service within the repo are you wanting to build
* environment: Indicates to the build step which properties file to run against.  Expected values are `[sandbox, nonprod, prod]`
* publish: Indicates whether you want to upload the resulting Docker image to AWS ECR
* save_libs: Used for code coverage to indicate whether you want to save the libs coverage report

**Example**

The example below shows how to run the build and run unit tests steps as well as publishing the image to AWS ECR
```yaml
- deploy-orb/build-and-test:
      <<: *ci-build
      name: build-and-test-gain-service
      environment: sandbox
      subproject: gain-service
      save_libs: true
      requires:
        - checkout-code
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

Does not require any parameters passed through.

**CircleCI Environment Variables**
* SNYK_TOKEN: API Token used to communicate with Snyk

**Example**
```yaml
  - deploy-orb/snyk-scan:
      name: snyk-scan
      <<: *ci-build
```
### tf-plan
**Description**

This step performs a linting step to make sure the terraform styling is standardised, and then runs a terraform plan - based on the files provided in the path parameter.

**Parameters**
* path: The path of the terraform files you are wanting to run against - **Note** remember to omit the root terraform directory from your path.  As shown in the hierarchy example below Journeys will typically contain a main and kubernetes subfolder.
* environment: Indicates which environment the code is being deployed to.  Expected values are `[sandbox, nonprod, prod]`
```
terraform
└───kubernetes
│   │   kubernetes1.tf
│   │   kubernetes2.tf
│   │
│   └───modules
│       │   exmaple3.tf
│       │   example4.tf
│       │   ...
│   
└───main
    │   service1.tf
    │   service2.tf
```

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

**Description**

This step performs a linting step to make sure the terraform styling is standardised, and then runs a terraform apply - based on the files provided in the path parameter.

**Parameters**
* path: The path of the terraform files you are wanting to run against - **Note** remember to omit the root terraform directory from your path.  As shown in the hierarchy example below Journeys will typically contain a main and kubernetes subfolder.
* environment: Indicates which environment the code is being deployed to.  Expected values are `[sandbox, nonprod, prod]`

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

### report-code-coverage
**Description**

This step generates a code coverage report and adds to your GitHub PR as comments.  To generate the report, the step [build-and-test](#build-and-test) need to of already completed.
 
**Parameters**

Does not require any parameters to be passed.  It does however need the following environment variables to be set `GITHUB_BOT_USERNAME` and `GITHUB_BOT_PACKAGE_MANAGER_TOKEN`

**Example**

```yaml
- deploy-orb/report-code-coverage:
      <<: *ci-build
      name: report-code-coverage
```