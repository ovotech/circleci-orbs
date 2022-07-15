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

### scan_python
This command will scan Python code for security vulnerabilities. It runs the tool
[Semgrep](https://semgrep.dev) to perform the scans.

**Parameters**
- `directory` - the directory containing the source code to scan. Defaults to the
  root of the repository.  

### scan_scala
This command will scan Scala code for security vulnerabilities. It runs the tool
[Semgrep](https://semgrep.dev) to perform the scans.

**Parameters**
- `directory` - the directory containing Scala code to scan. Defaults to the
  root of the repository.

### scan_typescript
This command will scan TypeScript code for security vulnerabilities. It runs the tool
[Semgrep](https://semgrep.dev) to perform the scans.

**Parameters**
- `directory` - the directory containing the source code to scan. Defaults to the
  root of the repository.  

### scan_terraform
This command runs [Checkov](https://www.checkov.io/) static code analysis via the CLI with the specified configuration options.

**Parameters**
- `directory` - directory with infrastructure code to scan
- `config_file` - checkov configuration file
- `baseline` - Path to a .checkov.baseline file to compare. Report will include only failed checks that are not in the baseline. If one is not specified, the orb will look for one in the directory and use that as a default


## Examples
### Simple Scan for scan_dockerfile command
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_dockerfile:
          dockerfile: circleci-orbs/sast/examples/Dockerfile
```
### Scan with ignore rules for scan_dockerfile command

In order to [ignore rules](https://github.com/hadolint/hadolint#rules) that would otherwise cause failed pipeline runs you can add them as a comma-seperated list after the parameter `ignore-rules`
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
```

### Simple Scan for scan_python command
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_python:
          directory: ./src
```

### Simple Scan for scan_scala command
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_scala:
          directory: ./src
```

### Simple Scan for scan_typescript command
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_typescript:
          directory: ./src
```

### Simple Scan for scan_terraform command
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_terraform:
          directory: terraform/examples
```
### Scan with a baseline for scan_terraform command

In order to generate a baseline against which you want to track changes, you can run the Checkov CLI locally with the following flag to create that baseline which you should then commit to version control:
```
  checkov -d terraform/examples/ --create-baseline
```

The baseline file keeps track of all the vulnerabilities in your IaC at the point when it was generated. On subsequent scans, Checkov will only fail if there are additional vulnerabilities discovered compared to the baseline file.

The following example shows how to run a scan with with the orb whilst passing in your baseline file:

```yaml
version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_terraform:
          directory: terraform/examples
          baseline: terraform/examples/.checkov.baseline
```
