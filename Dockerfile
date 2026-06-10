# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

FROM mirror.gcr.io/alpine:3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

ARG TARGETARCH
ARG VERSION
ARG FRAMEWORK

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  RADARR__UPDATE__BRANCH=nightly

USER root
WORKDIR /app

COPY --chown=0:0 --chmod=755 \
  packages/linux-musl-${TARGETARCH/amd64/x64}/${FRAMEWORK}/Radarr/ /app/radarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    bash \
    ca-certificates \
    catatonit \
    curl \
    icu-libs \
    tzdata \
    gnu-libiconv \
    file && \
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR__UPDATE__BRANCH}\nPackageVersion=${VERSION}" > /app/radarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/*

COPY root/ /

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

EXPOSE 7878

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
