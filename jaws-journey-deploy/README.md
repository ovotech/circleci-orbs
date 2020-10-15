# Smart Journeys (JAWS) Standard CircleCI Deployment

This orb provides a standard deployment process for all journey repositories to ensure common code between them.

### Jobs

Available Jobs
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

This circleci job checks out your repositories code, and persists it to a working directory

**Parameters**

Does not require any parameters to be provided

### avro

**Description**

This job performs two steps for the journey code bases.  
 1. Firstly it checks whether the version of the schema that the code would produce is compatible with the version of the schema currently in Aiven, 
 2. Uploads the schema to Aiven's schema registry. This feature is optional and can be switched off with `uploadschema` parameter

**Note** If you are not uploading the schema then the compatibility check will handle instances of the schema not being found in the schema registry.  This is to allow for testing without having to commit the schema 

**Parameters**

* uploadschema: Boolean value expected, which indicates whether you want to run the upload avro step.  Default value is false
* environment: Indicates to the build step which properties file to run against.  Expected values are `[sandbox, nonprod, prod]`

### build-and-test

**Description**

This job performs a few steps
1. Runs a gradle build on the service provided in `serviceName` parameter
2. Run unit tests
3. Saves the results of the unit tests to be used for code coverage
4. Publishes docker image to AWS ECR - if `publish` parameter is set to true

**Parameters**

* serviceName: Which service within the repo are you wanting to build
* environment: Indicates to the build step which properties file to run against.  Expected values are `[sandbox, nonprod, prod]`
* publish: Indicates whether you want to upload the resulting Docker image to AWS ECR
* save_libs: Used for code coverage to indicate whether you want to save the libs coverage report

### integration-test

**Description**

This job executes integration tests for the supplied service

**Parameters**

* serviceName: Which service within the repo are you wanting to build
* environment: Indicates to the build step which properties file to run against.  Expected values are `[sandbox, nonprod, prod]`

### run-automation-test

**Description**



**Parameters**

`environment` - indicates to the build step which properties file to run against.  Expected values are [sandbox, nonprod, prod]


### synk-scan

Performs a check to make sure your code dependencies do not introduce any new security vulnerabilities 

**Parameters**

Does not require any parameters passed through.

**CircleCI Environment Variables**
* SNYK_TOKEN: API Token used to communicate with Snyk

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

### tf-apply

**Description**

This step performs a linting step to make sure the terraform styling is standardised, and then runs a terraform apply - based on the files provided in the path parameter.

**Parameters**
* path: The path of the terraform files you are wanting to run against - **Note** remember to omit the root terraform directory from your path.  As shown in the hierarchy example below Journeys will typically contain a main and kubernetes subfolder.
* environment: Indicates which environment the code is being deployed to.  Expected values are `[sandbox, nonprod, prod]`


### notify-shipit

**Description**

Send a message to shipit API to indicate when a deployment has occurred

**Parameters**

Does not require any parameters passed through.  However it does require that you provide a SHIPIT_API_KEY within the project environment variables or context

### report-code-coverage
**Description**

This step generates a code coverage report and adds to your GitHub PR as comments.  To generate the report, the step [build-and-test](#build-and-test) need to of already completed.
 
**Parameters**

Does not require any parameters to be passed.  It does however need the following environment variables to be set `GITHUB_BOT_USERNAME` and `GITHUB_BOT_PACKAGE_MANAGER_TOKEN`

## Example Usage
```yaml
workflows:
  ci:
    jobs:
      - deploy-orb/checkout-code:
          filters: *ignore-master-branch
          name: checkout-code
      - deploy-orb/snyk-scan:
          name: snyk-scan
          <<: *ci-build
          requires:
            - checkout-code
      - deploy-orb/avro:
          name: avro-ci
          <<: *ci-build
          environment: sandbox
          requires:
            - checkout-code

      - deploy-orb/build-and-test:
          <<: *ci-build
          name: build-and-test-gain-service
          environment: sandbox
          serviceName: gain-service
          save_libs: true
          requires:
            - checkout-code

      - deploy-orb/build-and-test:
          <<: *ci-build
          name: build-and-test-gain-replay-service
          environment: sandbox
          serviceName: gain-replay-service
          save_libs: false
          requires:
            - checkout-code
      - deploy-orb/integration-test:
          name: integration-test-<< matrix.serviceName >>
          environment: sandbox
          matrix:
            alias:
              integration-test
            <<: *integration-test-services-matrix
          <<: *ci-build
          requires:
            - checkout-code
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
          requires:
            - checkout-code

      - deploy-orb/report-code-coverage:
          <<: *ci-build
          name: report-code-coverage
          requires:
            - build-and-test-gain-service
            - build-and-test-gain-replay-service
```