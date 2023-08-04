# Build scripts

This `orb` provides ability to publish release data (version and release notes) to release notes system on every successful semantic release occurrence. It works in conjunction with ArgoCD Notifications. Current orb is responsible for enrolling repo in release note system and provides versioning and release notes information, whereas ArgoCD provides deployment data. [Release Notes](https://github.com/ovotech/ohs-release-notes) application acts as a bridge and brings these pieces together. Web UI is available [here](release-notes.homeservices-nonprod.ovotech.org.uk)
## Requirements
- Repository should use semantic release versioning


## Commands

These are the defined commands in this `orb`
### <u>extract-release</u>

The `extract-release` command invokes the `extract-release.sh` script to ingest
semantic release data (version and release notes).
It runs semantic release in --dry-run mode that doesn't have any side effects
but allows to calculate if release will happen and collect required data. 

Parameters for this step:

| name | description | required |
| --- | --- | --- |
| `clone_folder` | Optional. Path to directory where scripts will be stored to | false

### <u>publish-release</u>

The `publish-release` command invokes the `publish-release.sh` script to publish collected data
to release notes github workflow.
Four bits of data are required when publishing release to release notes system:
* Application Name - has to match ArgoCD application name
* Release Version - is automatically collected by extract-release command
* Release Notes - also automatically collected by extract-release command
* Image names - comma separated list of images, that are built for ArgoCD application. Is used to match notifications coming from ArgoCD notification system.

Parameters for this step:

| name | description | required |
| --- | --- | --- |
| `application_name` | ArgoCD application name. Has to completely match including the case | true
| `image_names` | Comma separated list of images built for ArgoCD application | true
| `clone_folder` | Optional. Path to directory where scripts will be stored to | false

## Example configuration that uses this `orb`

The [Release Notes](https://github.com/ovotech/ohs-release-notes/blob/main/.circleci/config.yml) repository itself.

## Executors
This orb does not define any executors. It only provides re-usable commands