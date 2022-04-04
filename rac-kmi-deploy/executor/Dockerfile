FROM alpine:3.15

ARG SBT_VERSION
ENV SBT_VERSION ${SBT_VERSION:-1.6.2}

RUN set -x \
  && apk --update add --no-cache --virtual .build-deps curl \
  && ESUM="637637b6c4e6fa04ab62cd364061e32b12480b09001cd23303df62b36fadd440" \
  && SBT_URL="https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
  && apk add shadow \
  && apk add bash \
  && apk add openssh \
  && apk add rsync \
  && apk add git \
  && curl -Ls ${SBT_URL} > /tmp/sbt-${SBT_VERSION}.tgz \
  && sha256sum /tmp/sbt-${SBT_VERSION}.tgz \
  && (echo "${ESUM}  /tmp/sbt-${SBT_VERSION}.tgz" | sha256sum -c -) \
  && mkdir /opt/sbt \
  && tar -zxf /tmp/sbt-${SBT_VERSION}.tgz -C /opt/sbt \
  && sed -i -r 's#run \"\$\@\"#unset JAVA_TOOL_OPTIONS\nrun \"\$\@\"#g' /opt/sbt/sbt/bin/sbt \
  && apk del --purge .build-deps \
  && rm -rf /tmp/sbt-${SBT_VERSION}.tgz /var/cache/apk/*

RUN apk add openjdk11

# Install snyk
RUN apk add -q --no-progress --no-cache wget libstdc++ sudo \
  && wget -q https://static.snyk.io/cli/latest/snyk-alpine \
  && wget -q https://static.snyk.io/cli/latest/snyk-alpine.sha256 \
  && sha256sum -c snyk-alpine.sha256 \
  && sudo mv snyk-alpine /usr/local/bin/snyk \
  && sudo chmod +x /usr/local/bin/snyk \
  && snyk config set disableSuggestions=true

# Install Docker

# Docker.com returns the URL of the latest binary when you hit a directory listing
# We curl this URL and `grep` the version out.
# The output looks like this:

#>    # To install, run the following commands as root:
#>    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-17.05.0-ce.tgz && tar --strip-components=1 -xvzf docker-17.05.0-ce.tgz -C /usr/local/bin
#>
#>    # Then start docker in daemon mode:
#>    /usr/local/bin/dockerd

RUN set -ex \
  && apk --update add --no-cache --virtual .build-deps curl \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*\.tgz' | sort -r | head -n 1) \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

RUN id -u circleci 2> /dev/null || useradd --system --create-home --uid 1001 --gid 0 circleci

WORKDIR /home/circleci
RUN chown -R 1001:0 /home/circleci

USER 1001

ENV PATH="/opt/sbt/sbt/bin:$PATH" \
    JAVA_OPTS="-XX:+UseContainerSupport -Dfile.encoding=UTF-8" \
    SBT_OPTS="-Xmx2048M -Xss2M"

RUN sbt about -v && rm -rf project/
