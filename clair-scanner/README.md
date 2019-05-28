# Clair Scanner Orb

This orb can be used to scan docker images for vulnerabilities

To scan images in a private registry you must authenticate before
running the scan step. To authenticate with GCR, add a run step which
does something like:

    echo "$GCLOUD_SERVICE_KEY" | base64 --decode --ignore-garbage \
       > /tmp/google_creds.json
    docker login -u _json_key -p "$(cat /tmp/google_creds.json)" <repo url>

To authenticate with ECR, add a run step which does:

    $(aws ecr get-login --no-include-email)

Authenticating with dockerhub is a standard docker login.

### Whitelist

If the image contains unapproved vulnerabilities the build fails.
You can approve vulnerabilities using a whitelist file:

```yaml
generalwhitelist: #Approve CVE for any image
  CVE-2017-8804: glibc
  CVE-2016-2779: util-linux
  CVE-2017-1000379: linux
  CVE-2018-12930: linux
  CVE-2018-12931: linux
  CVE-2013-7445: linux
  CVE-2018-14615: linux
  CVE-2018-14609: linux
  CVE-2018-14614: linux
  CVE-2018-14612: linux
  CVE-2018-14613: linux
  CVE-2018-14611: linux
  CVE-2018-14610: linux
  CVE-2018-14616: linux
  CVE-2018-1000654: libtasn1-6
```

To use a whitelist, give the path in the whitelist parameter.

Many images contain dummy kernel headers which may be detected as
containing vulnerabilities, even though containers share the host kernel.
These need to be whitelisted. Vulnerabilities in other packages may not
be exploitable, which can be whitelisted. Review carefully.

## Executors

This orb defines a 'default' executor containing clair-scanner.
This executor also has the docker client and aws cli.

## Commands

### scan

This command scans docker images for vulnerabilities.
If credentials are required for docker to pull the image, they should be
provided in a previous step,

If the image contains any unapproved high severity vulnerabilities, the
build will fail. Vulnerabilities can be approved using a whitelist file.

Parameters:

- image: Name of the image to scan.
- image_file: Path to a file containing images to scan.
- whitelist: Path to a CVE whitelist
- severity_threshold: The threshold (equal and above) at which discovered vulnerabilities are reported. May be 'Defcon1', 'Critical', 'High', 'Medium', 'Low', 'Negligible' or 'Unknown'. The Default is 'High'.
- fail_on_discovered_vulnerabilities: Fail command when vulnerabilities at severity equal to or above the threshold are discovered. Default is true.

## Examples

### Scan a public image

```yaml

version: 2.1

orbs:
  clair_scanner: ovotech/clair-scanner@1

jobs:
  scan_images:
    executor: clair_scanner/default
    steps:
    - clair_scanner/scan:
        image: debian:stretch

workflows:
  test:
    jobs:
      - scan_images
```

### Scan images in GCR and ECR

Make sure to set the AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY variables
for ECR. For GCR set GCLOUD_SERVICE_KEY to a base64 encoded json key.

```yaml
version: 2.1

orbs:
  clair: ovotech/clair-scanner@1

jobs:
  scan_ecr:
    executor: clair/default
    steps:
    - run: $(aws ecr get-login --no-include-email)
    - clair/scan:
        image: 361339499037.dkr.ecr.eu-west-1.amazonaws.com/pe-orbs:latest

  scan_gcr:
    executor: clair/default
    steps:
    - run: |
       echo "$GCLOUD_SERVICE_KEY" | base64 --decode --ignore-garbage > /tmp/google_creds.json
       docker login -u _json_key -p "$(cat /tmp/google_creds.json)" gcr.io/pe-dev-185509/avn-python
    - clair/scan:
        image: gcr.io/pe-dev-185509/avn-python@sha256:f66e6ef17bba016f9dc9fccfe7b816b5dbf70757bd283680896ad83bb9c84a62

workflows:
  test:
    jobs:
    - scan_ecr
    - scan_gcr
```

### Scan images listed in a file

You can list image names or digests in a files and scan them all.
You can use this to build and scan the images you just built:

```yaml
version: 2.1

orbs:
  clair: ovotech/clair-scanner@1

jobs:
  scan_images:
    executor: clair/default
    steps:
    - run: |
        docker build -t ovotech/example_image .
        docker push ovotech/example_image
        echo $(docker image inspect --format="{{index .RepoDigests 0}}" ovotech/example_image) > /image.txt
    - clair/scan:
        image_file: /image.txt

workflows:
  test:
    jobs:
    - scan_images
```
