#!/usr/bin/env bash

set -e

docker build --tag "ovotech/terraform:${USER}_test_0.11" --file ../executor/Dockerfile-0.11 ../executor
docker build --tag "ovotech/terraform:${USER}_test_0.12" --file ../executor/Dockerfile-0.12 ../executor

cd ../../ && tools/include.py terraform/orb.yml >/tmp/terraform_orb.yml && cd terraform/test
sed -i -e "s|ovotech/terraform:0.11|ovotech/terraform:${USER}_test_0.11|" /tmp/terraform_orb.yml
sed -i -e "s|ovotech/terraform:0.12|ovotech/terraform:${USER}_test_0.12|" /tmp/terraform_orb.yml

docker push ovotech/terraform:test_0.11
docker push ovotech/terraform:test_0.12

circleci orb publish /tmp/terraform_orb.yml "ovotech/terraform@dev:${USER}_test" --token "$CIRCLECI_TOKEN"

cd tfswitch && bash test.sh && cd ..
cd registry && bash test.sh && cd ..
cd publish-module && bash test.sh && cd ..
