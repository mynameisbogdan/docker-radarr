# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG VERSION
ARG RADARR_BRANCH="nightly"

LABEL build_version=$VERSION
LABEL maintainer="nobody"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"
ENV DOTNET_CLI_TELEMETRY_OPTOUT=true

COPY build/_artifacts/linux-musl-x64/net8.0/Radarr/ /app/radarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}" > /app/radarr/package_info && \
  printf "Custom version: ${VERSION}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 7878

VOLUME /config
