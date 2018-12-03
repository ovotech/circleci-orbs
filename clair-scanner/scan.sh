#!/usr/bin/env bash

set -ex

if [ -z "<< parameters.image_file >><< parameters.image >>" ]; then
    echo "Either the image_file or image parameters must be present"
    exit -1
fi

DB=$(docker run -p 5432:5432 -d arminc/clair-db:latest)
CLAIR=$(docker run -p 6060:6060 --link $DB:postgres -d arminc/clair-local-scan:v2.0.1)
CLAIR_SCANNER=$(docker run -v /var/run/docker.sock:/var/run/docker.sock -d ovotech/clair-scanner:latest tail -f /dev/null)

clair_ip=$(docker exec -it $CLAIR hostname -i | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
scanner_ip=$(docker exec -it $CLAIR_SCANNER hostname -i | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

if [ -n "<< parameters.whitelist >>" ]; then
    cat "<< parameters.whitelist >>"
    docker cp "<< parameters.whitelist >>" $CLAIR_SCANNER:/whitelist.yml

    WHITELIST="-w /whitelist.yml"
fi

if [ -n "<< parameters.image_file >>" ]; then
    images=$(cat "<< parameters.image_file >>")
    for image in $images; do
        docker pull "$image"
        docker exec -it $CLAIR_SCANNER clair-scanner --ip ${scanner_ip} --clair=http://${clair_ip}:6060 -t High $WHITELIST "$image"
    done
else
    docker pull "<< parameters.image >>"
    docker exec -it $CLAIR_SCANNER clair-scanner --ip ${scanner_ip} --clair=http://${clair_ip}:6060 -t High $WHITELIST "<< parameters.image >>"
fi
