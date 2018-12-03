FROM debian:buster-slim

# This is the CI image used when building and publishing orbs
# It should be pushed to 361339499037.dkr.ecr.eu-west-1.amazonaws.com/pe-orbs:latest

RUN apt-get update \
 && apt-get install -y \
    git \
    ssh \
    tar \
    gzip \
    ca-certificates \
    curl \
    unzip \
    python \
    python3 \
    gnupg \
 && rm -rf /var/lib/apt/lists/*

# docker
RUN curl -sL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && echo "deb https://download.docker.com/linux/debian buster stable"  > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y \
      docker-ce \
 && rm -rf /var/lib/apt/lists/*

RUN curl https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh \
    --fail --show-error | bash
