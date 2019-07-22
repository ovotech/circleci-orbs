#!/usr/bin/env bash

set -e

cd ../../ && tools/include.py terraform/orb.yml >/tmp/terraform_orb.yml && cd terraform/test
circleci orb validate /tmp/terraform_orb.yml

sed -i -e "s|ovotech/terraform:0.11|ovotech/terraform:${USER}_test_0.11|" /tmp/terraform_orb.yml
sed -i -e "s|ovotech/terraform:0.12|ovotech/terraform:${USER}_test_0.12|" /tmp/terraform_orb.yml

docker build --tag "ovotech/terraform:${USER}_test_0.11" --file ../executor/Dockerfile-0.11 ../executor
docker build --tag "ovotech/terraform:${USER}_test_0.12" --file ../executor/Dockerfile-0.12 ../executor

circleci orb publish /tmp/terraform_orb.yml "ovotech/terraform@dev:${USER}_test" --token "$CIRCLECI_TOKEN"

DIR=$(pwd)
for TEST_DIR in github; do
    echo $TEST_DIR
    cd $DIR/$TEST_DIR
    ./test.sh
done

cd $DIR

echo "All Done"
