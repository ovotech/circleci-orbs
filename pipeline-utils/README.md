# Pipeline Utils
A collection of small commands that are designed to make crafting pipelines
easier.

## Commands

### configure-environment
Configures the correct environment variables according to the current
(prod/nonprod) environment. If your pipeline has the environment variables
`PROD_AWS_ACCESS_KEY_ID` and `NONPROD_AWS_ACCESS_KEY_ID`, this command will
allow you to set the environment variable `AWS_ACCESS_KEY_ID` to the
appropriate one.

Parameters:
* `env` - The name of the environment (prod/nonprod, etc) used as a prefix
* `vars` - Comma or space delimited list of environment variables to configure

Example:
```yaml
jobs:
  test:
    docker:
      - image: cimg/base:stable
    environment:
      NONPROD_SECRET_VALUE: "My nonprod secret"
      PROD_SECRET_VALUE: "My prod secret"
    steps:
      - pipeline-utils/configure-environment:
          env: nonprod
          vars: SECRET_VALUE
      - run: echo "${SECRET_VALUE}" # Returns "My nonprod secret"
```

### base64-decode
Base64 decodes an environment variable if it appears to be base64 encoded. If
not, will leave the environment variable alone.

Parameters:
* `var` - The name of an environment variable to base64 decode

Example:
```yaml
jobs:
  test:
    docker:
      - image: cimg/base:stable
    environment:
      SECRET_VALUE: TXkgbm9ucHJvZCBzZWNyZXQK
    steps:
      - pipeline-utils/base64-decode:
          var: SECRET_VALUE
      - run: echo "${SECRET_VALUE}" # Returns "My nonprod secret"
```
