# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.22

ARG VERSION

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  RADARR__UPDATE__BRANCH=nightly

USER root
WORKDIR /app

COPY --chown=0:0 --chmod=755 \
  build/_artifacts/linux-musl-x64/net8.0/Radarr/ /app/radarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    bash \
    ca-certificates \
    catatonit \
    icu-libs \
    sqlite-libs \
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
