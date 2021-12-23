# The docker image produced by this is intended for use by the helm-ci circleCI orb.
FROM alpine/helm:3.7.2

RUN wget https://github.com/instrumenta/kubeval/releases/latest/download/kubeval-linux-amd64.tar.gz
RUN tar xf kubeval-linux-amd64.tar.gz
RUN cp kubeval /usr/local/bin
