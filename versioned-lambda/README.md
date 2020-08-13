# Versioned AWS Lambda Build and Deploy CircleCI Orb

This orb can be used to build and deploy aliased, versioned AWS lamba functions.

The orb is designed with a workflow which makes use of published lambda
[versions](https://docs.aws.amazon.com/lambda/latest/dg/configuration-versions.html) and
[aliases](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html).

When using the `create-lambda-version` step, the orb will:

1. update the function code of the specified lambda (from the given build directory and lambda zip file).
2. publish a new version
3. assign the branch name as an alias for that version.

The orb also offers a `build-test-and-package` job, which runs a standardised node.js build to create the
zip file of the function code.

The orb includes an optional Snyk vulnerability scan step. To ensure this runs the CircleCI project will
need a SNYK_TOKEN to be included in the Environment Variables settings page. The severity level is set to low
in order to capture all vulnerabilities.

## Jobs

### node-test-and-package

This job builds the Node.js lambda function code and uploads the zip to S3. The job checks out the
source code, runs unit tests and linting before running the production build, zipping the distribution
and uploading to S3.

The built lambda zip artifact will be namespaced according to repo, branch and job SHA as follows:

```
s3://<< parameters.build-bucket >>/$CIRCLE_PROJECT_REPONAME/$CIRCLE_BRANCH/$CIRCLE_SHA1/<< parameters.lambda-zipfile >>
```

**NOTE:** The source code will be built into the `dist` folder in the packaged lambda function code.
You will need to check that the terraform defining the entry point references this directory e.g.:

```
resource "aws_lambda_function" "cool-lambda" {
  ...
  handler = "dist/handler.handler"
  ...
}
```

**Parameters**

- `executor` - Name of the executor to use for this job. Defaults a Node `12.x` image.
- `lambda-zipfile` - Name of the lambda zip file to be built. Defaults to `lambda.zip`.
- `build-bucket` - Name of the S3 bucket into which the built zip will be uploaded.
- `vulnerability-audit` - Whether or not to run `snyk` to check vulnerabilities. Defaults to `true`.
  When run, the build will fail if any dependency vulnerabilities are reported with a severity greater than
  or equal to "moderate". Requires the `SNYK_TOKEN` environment variable.
- `authenticate-npm` - Whether or not to authenticate access to the NPM registry. Defaults to `true`. Requires the
  `NPM_TOKEN` environment variable.

### create-lambda-version

This job updates the lambda function code, publishes a new version and creates an alias for
this version. The alias will be the branch name for all branches, which means that the `master`
alias will be updated to point to the latest version upon commit to `master`.

**NOTE:** this step assumes that the function code zip has been built into a bucket/key as defined
in the `build-test-and-package` job, i.e. using the repo name, branch and SHA.

**Parameters**

- `lambda-zipfile` - Name of the built lambda zip file. Defaults to `lambda.zip`.
- `build-bucket` - Name of the S3 bucket containing the built zip will be uploaded.
- `lambda-function-name` - Name of the Lambda function.
- `notify-shipit` - Whether or not to notify the `shipit` deployment service. Defaults to `false`.
  This should be set to `true` only when calling this job for a production deployment. Requires the
  `SHIPIT_API_KEY` and `TEAM_NAME` environment variables. Uses the
  [shipit orb](https://github.com/ovotech/pe-orbs/tree/master/shipit) with all default settings.

## Example

This is the simplest example of using the orb for the Migration team's preferred workflow. In the
example the `lambda-zipfile` argument is not provided so will default to `lambda.zip`. In situations
where one repo/workflow produces lambda functions from the same function zip, you will need to use
additional `create-lambda-version` jobs.

```yaml
version: 2.1

orbs:
  versioned-lambda: ovotech/versioned-lambda@1

workflows:
  version: 2
  build-test-deploy:
    jobs:
      - versioned-lambda/node-test-and-package:
          name: build-uat
          build-bucket: my-build-bucket
          context: my-uat-context

      - versioned-lambda/node-test-and-package:
          name: build-prod
          build-bucket: my-build-bucket
          context: my-prod-context
          filters:
            branches:
              only: master

      - versioned-lambda/create-lambda-version:
          name: deploy-uat
          build-bucket: my-build-bucket
          lambda-function-name: cool-lambda-uat
          requires:
            - test-and-package

      - hold:
          type: approval
          filters:
            branches:
              only: master
          requires:
            - deploy-uat
            - build-prod

      - versioned-lambda/create-lambda-version:
          name: deploy-prod
          build-bucket: my-build-bucket
          lambda-function-name: cool-lambda-prod
          notify-shipit: true
          filters:
            branches:
              only: master
          requires:
            - hold
```
