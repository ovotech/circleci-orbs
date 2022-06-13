# SAST CircleCI orb

This orb can be used to run the Hadolint analysis tool via the CLI against a target Dockerfile.

## Commands
### scan_dockerfile
This is the only command available in this orb currently. It runs [Hadolint](https://hub.docker.com/r/hadolint/hadolint) Dockerfile analysis via the CLI against a target Dockerfile with the specified configuration options.

**Parameters**
- `dockerfile` - directory containing a Dockerfile to scan
- `ignore-rules` - any vulnerability [rules](https://github.com/hadolint/hadolint#rules) you choose to ignore 
- `trusted-registries` - comma-separated list of trusted registries (e.g. `docker.io,my-company.com:5000`) if set, returns an error if Dockerfile use any images from registries not included in this list

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
```

### Scan with ignore rules

In order to [ignore rules](https://github.com/hadolint/hadolint#rules) that would otherwise cause failed pipeline runs you can add them as a comma-seperated list after the parameter `ignore-rules`
```yaml

version: '2.1'
orbs:
  sast: ovotech/sast@1
workflows:
  lint:
    jobs:
      - sast/scan_dockerfile:
          dockerfile: innovate/CPPE-135-sast-dockerfile
          ignore-rules: 'DL3018,DL3060'
```
