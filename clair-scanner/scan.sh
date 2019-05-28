#!/usr/bin/env bash

set -ex

if [ -z "<< parameters.image_file >><< parameters.image >>" ]; then
    echo "Either the image_file or image parameters must be present"
    exit -1
fi

REPORT_DIR=/clair-reports
mkdir $REPORT_DIR

DB=$(docker run -p 5432:5432 -d arminc/clair-db:latest)
CLAIR=$(docker run -p 6060:6060 --link $DB:postgres -d arminc/clair-local-scan:latest)
CLAIR_SCANNER=$(docker run -v /var/run/docker.sock:/var/run/docker.sock -d ovotech/clair-scanner:latest tail -f /dev/null)

clair_ip=$(docker exec -it $CLAIR hostname -i | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
scanner_ip=$(docker exec -it $CLAIR_SCANNER hostname -i | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

if [ -n "<< parameters.whitelist >>" ]; then
    cat "<< parameters.whitelist >>"
    docker cp "<< parameters.whitelist >>" $CLAIR_SCANNER:/whitelist.yml

    WHITELIST="-w /whitelist.yml"
fi

EXIT_STATUS=0

function scan() {
    local image=$1
    mkdir -p "$REPORT_DIR/$(dirname $image)"

    docker pull "$image"

    if ! docker exec -it $CLAIR_SCANNER clair-scanner --ip ${scanner_ip} --clair=http://${clair_ip}:6060 -t "<< parameters.severity_threshold >>" --report "/report.json" $WHITELIST "$image"; then
        EXIT_STATUS=1
    fi

    docker cp "$CLAIR_SCANNER:/report.json" "$REPORT_DIR/${image}.json"
}

if [ -n "<< parameters.image_file >>" ]; then
    images=$(cat "<< parameters.image_file >>")
    for image in $images; do
        scan $image
    done
else
    scan "<< parameters.image >>"
fi

if [ "<< parameters.fail_on_discovered_vulnerabilities >>" == "false" ]; then
    exit 0
else
    exit $EXIT_STATUS
fi
