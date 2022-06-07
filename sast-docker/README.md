# Initial installation and simple run commands

### Install hadolint
`$ brew install hadolint`

### Run hadolint locally on the Dockerfile from  the CLI
`$ hadolint Dockerfile`

### Run hadolint and pass your dockerfile as a docker container
`$ docker run --rm -i hadolint/hadolint < Dockerfile`

### Ignore specific evaluation condition example

You can specify as many ignores as you like, these can be run in combination with an ignore file as specified further below.

Ignore a single condition:
`$ hadolint --ignore DL3018 Dockerfile` 

Ignore mutiple conditions:
`$ hadolint --ignore DL3018 --ignore DL3060 Dockerfile` 


### Ignore a set of evaluations via local file
Create `.hadolint.yaml` file in local folder. This will be the default location for hadolint to check, so no need to specify.

Populate any ignore conditions as required.
```
ignored:
  - DL3060
```
run command 
`$ hadolint app/Dockerfile` 

### Ignore a set of evaluations in specific file & folder

Create `hadolint.yaml` file in desired location, you are required tto specify the config in the run command.

Populate any ignore conditions as required
```
ignored:
  - DL3060
  - DL3018
```

Run command specifying ignore configuration
`$ hadolint --config ~/../hadolint.yaml app/Dockerfile`
