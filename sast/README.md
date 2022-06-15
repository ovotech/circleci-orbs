# SAST CircleCI Orb

This orb can be used to run SAST analysis tools via the CI against your
codebase. It currently has support for scanning Dockerfiles, Terraform files and Scala, and more
will be coming soon. All tooling within this Orb has been selected in
cooperation with OVO SecEng.

## Commands
### install_semgrep
This command will install Semgrep into the environment ready for use. It allows
a version to be specified, but if none is selected it will install the latest
version.

**Parameters**
- `version` - the version of Semgrep to install. Defaults to the latest.

### scan_dockerfile
This command will scan a Dockerfile for security vulnerabilities. It runs the
tool [Hadolint](https://hub.docker.com/r/hadolint/hadolint).

**Parameters**
- `dockerfile` - the Dockerfile to scan.
- `ignore-rules` - comma-separated list of any vulnerability
  [rules](https://github.com/hadolint/hadolint#rules) you choose to ignore.
- `trusted-registries` - comma-separated list of trusted registries (e.g.
  `docker.io,my-company.com:5000`) if set, returns an error if Dockerfile
   use any images from registries not included in this list.

### scan_scala
This command will scan Scala code for security vulnerabilities. It runs the tool
[Semgrep](https://semgrep.dev) to perform the scans.

**Parameters**
- `directory` - the directory containing Scala code to scan. Defaults to the
  root of the repository.

### scan_terraform
This command runs [Checkov](https://www.checkov.io/) static code analysis via the CLI with the specified configuration options.

**Parameters**
- `directory` - directory with infrastructure code to scan
- `config_file` - checkov configuration file
- `baseline` - Path to a .checkov.baseline file to compare. Report will include only failed checks that are not in the baseline. If one is not specified, the orb will look for one in the directory and use that as a default

## Examples

### Simple Scan
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_dockerfile:
          dockerfile: circleci-orbs/sast/examples/Dockerfile
          ignore-rules: 'DL4005,DL3008'
          trusted-registries: 'docker.io'
      - sast/scan_scala:
          directory: ./src
      - sast/scan_terraform:
          directory: terraform/examples
```

