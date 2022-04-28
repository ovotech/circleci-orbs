
# SAST Terraform CircleCI orb

This orb can be used to run the static code analysis tools via the CLI against a target directory containing Terraform infrastructure-as-code.

## Commands
### checkov_static_code_analysis
This is the only command available in this orb. It runs [Checkov](https://www.checkov.io/) static code analysis via the CLI with the specified configuration options.

**Parameters**
- `directory` - directory with infrastructure code to scan
- `config_file` - checkov configuration file
- `baseline` - Path to a .checkov.baseline file to compare. Report will include only failed checks that are not in the baseline. If one is not specified, the orb will look for one in the directory and use that as a default

## Examples

### Simple Scan
```yaml
version: 2.1

orbs:
  sast-terraform: ovotech/sast-terraform@1

executors:
  python:
    docker:
    - image: circleci/python:3.9

jobs:
  run-checkov:
    executor: python
    steps:
    - sast-terraform/checkov_static_code_analysis:
        directory: terraform/examples

workflows:
  test-workflow:
    jobs:
    - run-checkov
        name: Checkov
```

### Scan with a baseline

In order to generate a baseline against which you want to track changes, you can run the Checkov CLI locally with the following flag to create that baseline which you should then commit to version control:
```
  checkov -d terraform/examples/ --create-baseline
```

The baseline file keeps track of all the vulnerabilities in your IaC at the point when it was generated. On subsequent scans, Checkov will only fail if there are additional vulnerabilities discovered compared to the baseline file.

The following example shows how to run a scan with with the orb whilst passing in your baseline file:
```yaml
version: 2.1

orbs:
  sast-terraform: ovotech/sast-terraform@1

executors:
  python:
    docker:
    - image: circleci/python:3.9

jobs:
  run-checkov:
    executor: python
    steps:
    - sast-terraform/checkov_static_code_analysis:
        directory: terraform/examples
        baseline: terraform/examples/.checkov.baseline

workflows:
  test-workflow:
    jobs:
    - run-checkov
        name: Checkov
```
