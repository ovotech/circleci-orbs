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

FOUND_UNAPPROVED_VULERNERABILITIES=0
FOUND_UNSUPPORTED_IMAGE=0
FOUND_UNKNOWN_EXIT_STATUS=0

function scan() {
    local image=$1
    mkdir -p "$REPORT_DIR/$(dirname $image)"

    docker pull "$image"

    ret=0 &>/dev/null
    docker exec -it $CLAIR_SCANNER clair-scanner --ip ${scanner_ip} --clair=http://${clair_ip}:6060 -t "<< parameters.severity_threshold >>" --report "/report.json" --log "/log.json" $WHITELIST --reportAll=true --exit-when-no-features=false "$image" > /dev/null 2>&1 || ret=$? &>/dev/null

    if [ $ret -eq 0 ] &>/dev/null; then
        echo "No unapproved vulernabilities"
    elif [ $ret -eq 1 ] &>/dev/null; then
        echo "Unapproved vulernabilities found"
        FOUND_UNAPPROVED_VULERNERABILITIES=1 &>/dev/null
    elif [ $ret -eq 5 ] &>/dev/null; then
        echo "Image was not scanned, not supported."
        FOUND_UNSUPPORTED_IMAGE=1 &>/dev/null
    else
        echo "Unknown clair-scanner return code $ret."
        FOUND_UNKNOWN_EXIT_STATUS=1 &>/dev/null
    fi

    if docker cp "$CLAIR_SCANNER:/report.json" "$REPORT_DIR/${image}.json"; then
        docker exec -it $CLAIR_SCANNER rm "/report.json"
    fi
}

if [ -n "<< parameters.image_file >>" ]; then
    images=$(cat "<< parameters.image_file >>")
    for image in $images; do
        scan $image
    done
else
    scan "<< parameters.image >>"
fi

EXIT_STATUS=0
if [ $FOUND_UNKNOWN_EXIT_STATUS -eq 1 ] &>/dev/null; then
    echo "Found unknown exit status"
    EXIT_STATUS=1 &>/dev/null
fi

if [ $FOUND_UNSUPPORTED_IMAGE -eq 1 ] && [ "<< parameters.fail_on_unsupported_images >>" == "true" ] &>/dev/null; then
    echo "Found unsupported image"
    EXIT_STATUS=1 &>/dev/null
fi

if [ $FOUND_UNAPPROVED_VULERNERABILITIES -eq 1 ] && [ "<< parameters.fail_on_discovered_vulnerabilities >>" == "true" ] &>/dev/null; then
    echo "Found unapproved vulernerabilities"
    EXIT_STATUS=1 &>/dev/null
fi

exit $EXIT_STATUS
