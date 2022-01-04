# R&C Google Cloud deploy CircleCIorb

This orb can be used to deploy scala services to a kubernetes cluster running in Google Cloud. 

## Executors
This orb defines two executors. The default one, a `docker` executor and a `machine` one, needed for the running service tests running in docker.

## Jobs
### compile
This job checkouts the source code and compiles it using sbt. After successful compilation, it caches the dependencies and persists everything into the workspace. 

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to persist the workspace. Defaults to `~/project`.
- `ssh-key-fingerprint` - The fingerprint of the ssh key with read permissions.

### unit_test
This job will restore the workspace, which contains all the source code and also the compiled source. It then executes unit testing.

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to restore the workspace. Defaults to `~/project`.

### service-tests-with-docker
This job is intended to execute service tests that uses Docker. 
It will restore the workspace, which contains all the source code and also the compiled source. It then executes service tests.

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `machine` executor.
- `workspace-dir` - Path to restore the workspace. Defaults to `~/project`.

### notify_shipit
This job will notify Shipit that a release was made. The notification includes a link to CircleCi build and Github commit that triggered the release. The git username is used to filter out commits by the provided username.

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to restore the workspace. Defaults to `~/project`.
- `shipit-api-key` - Name of the environment variable storing the api key to access ShipIt. Defaults to `SHIPIT_API_KEY`.
- `team-name` - Name of the environment variable storing the team name. Defaults to `TEAM_NAME`.
- `git-username` - Name of the environment variable storing the git username. Defaults to `GIT_USERNAME`.
- `shipit-url` - Name of the environment variable storing the url for shipit. Defaults to `SHIPIT_URL`.

### release
This job will bundle the service into a docker image and publish the generated image to `UAT` and `PRD` Google Container Registry.

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to restore/save the workspace. Defaults to `~/project`.
- `git-username` - Name of the environment variable storing the git username. Defaults to `GIT_USERNAME`.
- `git-user-email` - Name of the environment variable storing the email of the github user to use when pushing commits. Defaults to `GIT_USER_EMAIL`.
- `ssh-key-fingerprint` - The fingerprint of the ssh key with permissions to checkout.
- `google-cloud-sdk-version` - The version of google cloud sdk to install. Defaults to `246.0.0-0`.
- `google-compute-zone` - The Google compute zone to connect with via the gcloud CLI. Defaults to `europe-west1-b`.
- `cluster-name` - Name of the environment variable storing the Kubernetes cluster name. Defaults to `K8S_CLUSTER_NAME`.
- `container-name` - Name of environment variable storing the name of the container we are publishing. Defaults to `CIRCLE_PROJECT_REPONAME`.
- `registry-url` - The GCR registry URL. Defaults to `grc.io`.
- `uat-gcloud-service-key` - Name of environment variable storing the full service key JSON file for the UAT Google project. Defaults to `NONPROD_GCLOUD_ACCOUNT_AUTH`.
- `uat-project-id` - The UAT Google project ID to connect with via the gcloud CLI. Defaults to `NONPROD_PROJECT_ID`.
- `prd-gcloud-service-key` - Name of environment variable storing the full service key JSON file for the PRD Google project. Defaults to `PRD_GCLOUD_ACCOUNT_AUTH`.
- `prd-project-id` - Name of environment variable storing the PRD Google project ID to connect with via the gcloud CLI. Defaults to `PRD_PROJECT_ID`.

### uat-deploy
This job will run the `helm` deployment and deploy the resources into the uat kubernetes cluster.
**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to restore the workspace. Defaults to `~/project`.
- `google-cloud-sdk-version` - The version of google cloud sdk to install. Defaults to `246.0.0-0`.
- `google-compute-zone` - The Google compute zone to connect with via the gcloud CLI. Defaults to `europe-west1-b`.
- `cluster-name` - Name of the environment variable storing the Kubernetes cluster name. Defaults to `K8S_CLUSTER_NAME`.
- `helm-release-name` - Name of environment variable storing the helm release name. Defaults to `CIRCLE_PROJECT_REPONAME`.
- `uat-gcloud-service-key` - Name of environment variable storing the full service key JSON file for the UAT Google project. Defaults to `NONPROD_GCLOUD_ACCOUNT_AUTH`.
- `uat-project-id` - The UAT Google project ID to connect with via the gcloud CLI. Defaults to `NONPROD_PROJECT_ID`.

### prd-deploy
This job will run the `helm` deployment and deploy the resources into the production kubernetes cluster.

**Parameters**
- `executor` - : Name of executor to use for this job. Defaults to `docker` executor.
- `workspace-dir` - Path to restore the workspace. Defaults to `~/project`.
- `google-cloud-sdk-version` - The version of google cloud sdk to install. Defaults to `246.0.0-0`.
- `google-compute-zone` - The Google compute zone to connect with via the gcloud CLI. Defaults to `europe-west1-b`.
- `cluster-name` - Name of the environment variable storing the Kubernetes cluster name. Defaults to `K8S_CLUSTER_NAME`.
- `helm-release-name` - Name of environment variable storing the helm release name. Defaults to `CIRCLE_PROJECT_REPONAME`.
- `prd-gcloud-service-key` - Name of environment variable storing the full service key JSON file for the PRD Google project. Defaults to `PRD_GCLOUD_ACCOUNT_AUTH`.
- `prd-project-id` - The PRD Google project ID to connect with via the gcloud CLI. Defaults to `PRD_PROJECT_ID`.

## Example
This is the simplest way of creating a workflow that uses the provided jobs. It assumes that all default environment variables are set up in CircleCi.
It will compile, run unit test and build a docker image that is pushed to the container registry. It then deploys to `UAT` and `PRD` in parallel and sends a notification to Shipit if the `PRD` deploy is successful.

`Release`, `uat-deploy`, `prd-deploy` and `notify-ship` will only execute on `master` branch.

```yaml
version: 2.1

orbs:
  orb: ovotech/rac-gcp-deploy@1
 
workflows:
  build_and_deploy:
    jobs:
      - orb/compile:
          ssh-key-fingerprint: "SO:ME:FIN:G:ER:PR:IN:T"
      - orb/unit_test:
          requires:
            - orb/compile
      - orb/release:
          ssh-key-fingerprint: "SO:ME:FIN:G:ER:PR:IN:T"
          requires:
            - orb/unit_test
          filters:
            branches:
              only: master
      - orb/uat-deploy:
          requires:
            - orb/release
          filters:
            branches:
              only: master
      - orb/prd-deploy:
          requires:
            - orb/release
          filters:
            branches:
              only: master
      - orb/notify_shipit:
          requires:
           - orb/prd-deploy
          filters:
            branches:
              only: master
```
