FROM golang:1.12.6 AS tfmask

RUN git clone https://github.com/cloudposse/tfmask.git
RUN cd tfmask && make && make go/build

FROM debian:buster-slim

# This is the default executor image in the terraform orb

ARG TF_VERSION=0.11.14
ARG GCLOUD_VERSION=247.0.0
ARG HELM_VERSION=2.14.1
ARG TF_HELM_VERSIONS="0.6.0 0.5.1 0.5.0 0.4.0 0.3.2 0.3.1 0.3.0 0.2.0 0.1.0"
ARG TF_ACME_VERSIONS="1.0.0 0.6.0 0.5.0 0.4.0 0.3.0"

ENV TF_IN_AUTOMATION=yep

RUN apt-get update && apt-get install -y \
    git \
    ssh \
    tar \
    gzip \
    ca-certificates \
    curl \
    unzip \
    python2 \
    python3 \
    python3-requests \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip -o terraform.zip \
 && unzip terraform.zip \
 && mv terraform /usr/local/bin \
 && rm -rf terraform*

RUN mkdir -p /root/.terraform.d/plugins \
 && curl -sL https://s3-eu-west-1.amazonaws.com/terraform-provider-aiven/master/terraform-provider-aiven_linux_amd64.zip \
      -o terraform-provider-aiven_linux_amd64.zip \
 && unzip terraform-provider-aiven_linux_amd64.zip \
 && mv terraform-provider-aiven /root/.terraform.d/plugins \
 && rm -rf terraform*

RUN curl -sL "https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz" | tar -xzvf- \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -rf helm*.tar.gz linux-amd64/ \
 && helm init --client-only
ENV HELM_HOME /root/.helm

# This is extremely slow for some reason
RUN for TF_HELM_VERSION in $TF_HELM_VERSIONS; do \
      curl -L "https://github.com/terraform-providers/terraform-provider-helm/releases/download/v${TF_HELM_VERSION}/terraform-provider-helm_v${TF_HELM_VERSION}_linux_amd64.tar.gz" | tar -xzvf- \
      && mv terraform-provider-helm_linux_amd64/terraform-provider-helm /root/.terraform.d/plugins/terraform-provider-helm_v${TF_HELM_VERSION} \
      && rm -rf terraform-provider-helm*; \
    done

# acme provider
RUN for TF_ACME_VERSION in $TF_ACME_VERSIONS; do \
      curl -L https://github.com/vancluever/terraform-provider-acme/releases/download/v${TF_ACME_VERSION}/terraform-provider-acme_v${TF_ACME_VERSION}_linux_amd64.zip -o acme.zip \
      && unzip acme.zip -d /root/.terraform.d/plugins \
      && rm acme.zip \
      && mv /root/.terraform.d/plugins/terraform-provider-acme /root/.terraform.d/plugins/terraform-provider-acme_v${TF_ACME_VERSION}; \
    done

RUN curl -sL https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -o /opt/google-cloud-sdk.tar.gz \
 && cd /opt; tar -xf google-cloud-sdk.tar.gz \
 && rm google-cloud-sdk.tar.gz
ENV PATH "/opt/google-cloud-sdk/bin:$PATH"

RUN pip3 install awscli

RUN mkdir -p /usr/local/share/terraform/plugin-cache
ENV TF_PLUGIN_CACHE_DIR=/usr/local/share/terraform/plugin-cache

COPY --from=tfmask /go/tfmask/release/tfmask /usr/local/bin/tfmask
ENV TFMASK_RESOURCES_REGEX="(?i)^(random_id|kubernetes_secret|acme_certificate).*$"

ENTRYPOINT ["/usr/local/bin/terraform"]
