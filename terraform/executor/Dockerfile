# The docker image produced by this is intended to be used by the terraform-v2
# orb.
FROM debian:buster-slim

ARG TFMASK_VERSION="0.7.0"
ARG TFSWITCH_VERSION=0.13.1275
ARG GCLOUD_VERSION=329.0.0
ARG AWSCLI_VERSION=1.19.16
ARG HELM3_VERSION=3.5.3

# internal providers
ARG TF_OVO_VERSIONS="1.0.0"
ARG TF_AIVEN_KAFKA_USERS_VERSIONS="0.0.1 1.0.1 1.0.2 1.0.3 1.0.4 1.0.5 1.0.6 1.0.7 1.0.8 1.0.9"

# Terraform environment variables
ENV CHECKPOINT_DISABLE=true
ENV TF_IN_AUTOMATION=yep
ENV TF_INPUT=false
ENV TF_PLUGIN_CACHE_DIR=/usr/local/share/terraform/plugin-cache

RUN apt-get update && apt-get install -y \
    git \
    ssh \
    tar \
    gzip \
    ca-certificates \
    curl \
    unzip \
    jq \
    python3 \
    python3-setuptools \
    python3-requests \
    python3-pip \
    wget \
 && rm -rf /var/lib/apt/lists/*

# tfmask
RUN curl -fsL https://github.com/cloudposse/tfmask/releases/download/${TFMASK_VERSION}/tfmask_linux_amd64 -o tfmask \
 && mv tfmask /usr/local/bin

# tfswitch
RUN curl -fsL https://github.com/warrensbox/terraform-switcher/releases/download/${TFSWITCH_VERSION}/terraform-switcher_${TFSWITCH_VERSION}_linux_amd64.tar.gz -o tfswitch.tar.gz \
    && tar -xvf tfswitch.tar.gz tfswitch \
    && mv tfswitch /usr/local/bin \
    && rm -rf tfswitch.tar.gz
RUN mkdir -p $TF_PLUGIN_CACHE_DIR

# kafka users ovo provider
RUN mkdir -p /root/.terraform.d/plugins \
 && for TF_OVO_VERSION in $TF_OVO_VERSIONS; do \
      curl -f -L https://ovo-kafka-user.s3-eu-west-1.amazonaws.com/terraform-provider-ovo/${TF_OVO_VERSION}/terraform-provider-ovo_${TF_OVO_VERSION}_linux_amd64.zip -o ovo.zip \
      && mkdir -p /root/.terraform.d/plugins/terraform.ovotech.org.uk/pe/ovo/${TF_OVO_VERSION}/linux_amd64 \
      && unzip ovo.zip -d /root/.terraform.d/plugins \
      && unzip ovo.zip -d /root/.terraform.d/plugins/terraform.ovotech.org.uk/pe/ovo/${TF_OVO_VERSION}/linux_amd64 \
      && rm ovo.zip; \
    done

# aiven_kafka_users provider
RUN for TF_AIVEN_KAFKA_USERS_VERSION in $TF_AIVEN_KAFKA_USERS_VERSIONS; do \
      curl -f -L https://kafka-users-prod-tf-provider.s3-eu-west-1.amazonaws.com/terraform-provider-aiven-kafka-users/${TF_AIVEN_KAFKA_USERS_VERSION}/terraform-provider-aiven-kafka-users_${TF_AIVEN_KAFKA_USERS_VERSION}_linux_amd64.zip -o aiven-kafka-users.zip \
      && mkdir -p /root/.terraform.d/plugins/terraform.ovotech.org.uk/pe/aiven-kafka-users/${TF_AIVEN_KAFKA_USERS_VERSION}/linux_amd64 \
      && unzip aiven-kafka-users.zip -d /root/.terraform.d/plugins \
      && unzip aiven-kafka-users.zip -d /root/.terraform.d/plugins/terraform.ovotech.org.uk/pe/aiven-kafka-users/${TF_AIVEN_KAFKA_USERS_VERSION}/linux_amd64 \
      && rm aiven-kafka-users.zip; \
    done

# helm 3
RUN curl -fsL "https://get.helm.sh/helm-v${HELM3_VERSION}-linux-amd64.tar.gz" | tar -xzvf- \
 && mv linux-amd64/helm /usr/local/bin/helm3 \
 && rm -rf helm*.tar.gz linux-amd64/ \
 && ln -s /usr/local/bin/helm3 /usr/local/bin/helm

# gcloud
RUN curl -fsL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -o /opt/google-cloud-sdk.tar.gz \
 && cd /opt; tar -xf google-cloud-sdk.tar.gz \
 && rm google-cloud-sdk.tar.gz
ENV PATH "/opt/google-cloud-sdk/bin:$PATH"

# awscli
RUN pip3 install awscli==$AWSCLI_VERSION
# Upgrade requests lib again to prevent RequestsDependencyWarning for urllib3 and chardet
RUN pip3 install --upgrade requests

ENV TFMASK_RESOURCES_REGEX="(?i)^(random_id|kubernetes_secret|acme_certificate).*$"

COPY compact_plan.py /usr/local/bin/compact_plan

ENTRYPOINT ["/usr/local/bin/terraform"]
