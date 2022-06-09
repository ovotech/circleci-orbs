# SAST Dockerfile scanning with Hadolint

## Initial local installation of Hadolint and simple run commands
#### Install hadolint locally
`$ brew install hadolint`

#### Run hadolint locally on a Dockerfile from  the CLI
`$ hadolint Dockerfile`

#### Run hadolint and pass your dockerfile as a docker container
`$ docker run --rm -i hadolint/hadolint < Dockerfile`

#### Ignore specific evaluation condition example

You can specify as many ignores as you like, these can be run in combination with an ignore file as specified further below.

Ignore a single condition:
`$ hadolint --ignore DL3018 Dockerfile` 

Ignore mutiple conditions:
`$ hadolint --ignore DL3018 --ignore DL3060 Dockerfile` 

#### Ignore a set of evaluations via local file
Create `.hadolint.yaml` file in local folder. This will be the default location for hadolint to check, so no need to specify.

Populate any ignore conditions as required.
```
ignored:
  - DL3060
```
run command 
`$ hadolint app/Dockerfile` 

#### Ignore a set of evaluations in specific file & folder

Create `hadolint.yaml` file in desired location, you are required tto specify the config in the run command.

Populate any ignore conditions as required
```
ignored:
  - DL3060
  - DL3018
```

Run command specifying ignore configuration
`$ hadolint --config ~/../hadolint.yaml app/Dockerfile`


---

# SAST Dockerfile CircleCI orb

This orb can be used to run the Hadolint analysis tool via the CLI against a target directory containing a Dockerfile.

## Commands
### hadolint_scan
This is the only command available in this orb. It runs [Hadolint](https://hub.docker.com/r/hadolint/hadolint) Dockerfile analysis via the CLI with the specified configuration options.

**Parameters**
- `dockerfiles` - directory containing a Dockerfile to scan
- `ignore-rules` - any vulnerability [rules](https://github.com/hadolint/hadolint#rules) you choose to ignore 
- `trusted-registries` - comma-separated list of trusted registries (e.g. `docker.io,my-company.com:5000`) if set, returns an error if Dockerfiles use any images from registries not included in this list

## Examples

### Simple Scan
```yaml
description: >
  Sample usage of Hadolint Docker orb.

usage:
  version: '2.1'
  orbs:
    docker: circleci/docker@2.1.1
  workflows:
    lint:
      jobs:
        - sast-docker-dev/hadolint_scan:
            dockerfiles: innovate/CPPE-135-sast-dockerfile
```

### Scan with ignore rules

In order to [ignore rules](https://github.com/hadolint/hadolint#rules) that would otherwise cause failed pipeline runs you can add them as a comma-seperated list after the parameter `ignore-rules`
```yaml
description: >
  Sample usage of Hadolint Docker orb with ignore rules.

usage:
  version: '2.1'
  orbs:
    docker: circleci/docker@2.1.1
  workflows:
    lint:
      jobs:
        - sast-docker-dev/hadolint_scan:
            dockerfiles: innovate/CPPE-135-sast-dockerfile
            ignore-rules: 'DL3018,DL3060'
```
