# Orion Migration AWS Lambda Build and Deploy CircleCI Orb

This orb can be used to build and deploy AWS lamba functions.

The orb is designed with the Migration team workflow in mind, which involves using
published and aliased versions of AWS Lambdas. The orb currently only supports building the
lambda function code zip file from node.js (12.x by default) but the steps can be used
independently if you need to define a custom job to build the zip file.

## Jobs

### node-test-and-package

This job builds the Node.js lambda function code and uploads the zip to S3. The job checks out the
source code, runs unit tests and linting before running the production build, zipping the distribution
and uploading to S3.

The built lambda zip artifact will be namespaced according to repo, branch and job SHA as follows:

```
s3://<< parameters.build-bucket >>/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BRANCH/$CIRCLE_SHA1/<< parameters.lambda-zipfile >>
```

**Parameters**

- `executor` - : Name of the executor to use for this job. Defaults to the `lambci/lambda:build-nodejs12.x`
  docker image.
- `lambda-zipfile` - : Name of the lambda zip file to be built. Defaults to `lambda.zip`.
- `build-bucket` - : Name of the S3 bucket into which the built zip will be uploaded.

### create-lambda-version

This job updates the lambda function code, publishes a new version and creates an alias for
this version. The alias will be the branch name for all branches, which means that the `master`
alias will be updated to point to the latest version upon commit to `master`.

**Parameters**

- `lambda-zipfile` - : Name of the built lambda zip file. Defaults to `lambda.zip`.
- `build-bucket` - : Name of the S3 bucket containing the built zip will be uploaded.
- `lambda-function-name` - : Name of the Lambda function.

## Example

This is the simplest example of using the orb for the Migration team's preferred workflow. In the
example the `lambda-zipfile` argument is not provided so will default to `lambda.zip`. In situations
where one repo/workflow produces multiple zip files, you will need to use at least one non-default
name for the artifact.

```yaml
version: 2.1

orbs:
  migration-lambdas: ovotech/migration-lambdas@1

workflows:
  version: 2
  build-test-deploy:
    jobs:
      - migration-lambdas/node-test-and-package:
          name: test-and-package
          build-bucket: ovo-migration-lambda-builds
      - migration-lambdas/create-lambda-version:
          name: create-lambda-uat
          build-bucket: ovo-migration-lambda-builds
          lambda-function-name: cool-lambda-uat
          requires:
            - test-and-package
      - hold:
          filters:
            branches:
              only: master
          type: approval
          requires:
            - create-lambda-uat
      - migration-lambdas/create-lambda-version:
          name: create-lambda-prod
          build-bucket: ovo-migration-lambda-builds
          lambda-function-name: cool-lambda-prod
          filters:
            branches:
              only: master
          requires:
            - hold
```
