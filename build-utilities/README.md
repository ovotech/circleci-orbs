# Build scripts

This `orb` is providing a bunch of repetitive and generic commands to help with the creation of `docker` images in `circleci`.

The commands can be used to target the creation of multi arch images which can then be stored in your  container repository

## Commands

These are the defined commands in this `orb`
### <u>clone</u>

All scripts are stored in an internal `ovotech` [repo](https://github.com/ovotech/ohs-build-scripts) called `ohs-build-scripts`. This command can be used to clone that repo inside of your `circleci` pipeline to have them available to you.

Parameters for this step:

| name | description |
| --- | --- |
| `git_repo` | Git repository to clone |
| `local_folder` | Local folder path where the git repo will be cloned to |

### <u>build</u>

The `build` command invokes the `build-image.sh` script to build your docker image in the targeted architecture. It uses `docker buildx` under the hood. 

It is recommended that when you target a specific processor architecture (`amd64` or `arm64`) that you build it on a machine using the same architecture as otherwise `docker buildx` will use some emulation that could lead to very long build times.

When you target multiple architectures at the same time, you can run parallel builds in `circleci` and save the images to a workspace. This is covered by the next command.

Parameters for this step:

| name | description | accepted values |
| --- | --- | --- |
| `architecture` | Targeted processor architecture desired | `arm64`, `amd64` |
| `image_name` | Docker image name |
| `docker_registry` | Docker registry |
| `docker_file` | Docker file name + location |
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