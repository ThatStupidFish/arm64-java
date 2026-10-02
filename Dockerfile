# syntax=docker/dockerfile:1
ARG JAVA_VERSION=21

FROM eclipse-temurin:${JAVA_VERSION}-jdk-noble

ARG JAVA_VERSION
LABEL org.opencontainers.image.source="https://github.com/ThatStupidFish/arm64-java" \
      org.opencontainers.image.description="Eclipse Temurin ${JAVA_VERSION} image for Pterodactyl and Pelican panels (amd64 + arm64)"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fontconfig \
        git \
        iproute2 \
        jq \
        libfreetype6 \
        libstdc++6 \
        lsof \
        openssl \
        sqlite3 \
        tar \
        tini \
        tzdata \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -d /home/container -s /bin/bash container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY --chmod=0755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
