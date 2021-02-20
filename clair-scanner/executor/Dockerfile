FROM golang:1.15-buster as build

RUN apt-get update && apt-get install -y \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN go get -u github.com/golang/dep/cmd/dep
RUN git clone https://github.com/arminc/clair-scanner.git src/clair-scanner/
RUN cd src/clair-scanner/ \
 && make ensure \
 && make build

FROM debian:stretch-slim

RUN apt-get update && apt-get install -y \
    git \
    ssh \
    tar \
    gzip \
    ca-certificates \
    apt-transport-https \
    curl \
    gnupg2 \
    software-properties-common \
    python-pip \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" \
 && apt-get update && apt-get install -y \
    docker-ce \
 && rm -rf /var/lib/apt/lists/*

RUN pip install awscli

COPY --from=build /go/src/clair-scanner/clair-scanner /usr/local/bin
