# Build scripts

This `orb` provides ability to publish release data (version and release notes) to ohs-release-notes.

## Commands

These are the defined commands in this `orb`
### <u>clone</u>

Execution scripts are stored in an internal `ovotech` [repo](https://github.com/ovotech/ohs-release-notes) called `ohs-release-notes`.
This command can be used to clone that repo inside of your `circleci` pipeline to have them available to you.

Parameters for this step:

| name | description | required |
| --- | --- |------|
| `git_repo` | Git repository to clone | false |
| `local_folder` | Local folder path where the git repo will be cloned to | true |

### <u>extract</u>

The `extract` command invokes the `extract-release.sh` script to ingest
semantic release data (version and release notes).
It runs semantic release in --dry-run mode that doesn't have any side effects
but allows to calculate if release will happen and ingest required data. 

Parameters for this step:

| name | description | accepted values |
| --- | --- | --- |
| `clone_folder` | Clone build-script folder |
| `working_dir` | Optional working directory |

### <u>save-image</u>

This step can be used to save your docker images to a `circleci` [workspace](https://circleci.com/docs/workspaces/)

Parameters for this step:

| name | description |
| --- | --- |
| `image_name` | Docker image name to save |
| `path_name` | Path name where the image will be saved |
| `root_name` | Root folder name where the image will be saved |

This will use the `docker save` command that will create a `.tar` file

### <u>restore_images</u>

Restores all images saved in a `circleci` workspace. 

Parameters for this step:

| name | description |
| --- | --- |
| `path_name` | Path name where the image will be loaded from |
| `root_name` | Root folder name where the image will be loaded from |

## Example configuration that use that `orb`

The [Customer signup](https://github.com/ovotech/homeservices-customer-signup/blob/main/.circleci/config.yml) API `config.yml` file is one example of that orb being used. 

It shows how a multi arch image is created for `arm64` and `amd64` based processors and to use the steps described here.

## Executors

This orb does not define any executors. It only provides re-usable commands