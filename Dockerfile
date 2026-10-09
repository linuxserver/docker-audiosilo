# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.24

# set version label
ARG BUILD_DATE
ARG VERSION
ARG AUDIOSILO_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="KodeStar"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    ffmpeg && \
  echo "**** install audiosilo ****" && \
  if [ -z ${AUDIOSILO_RELEASE+x} ]; then \
    AUDIOSILO_RELEASE=$(curl -sX GET "https://api.github.com/repos/KodeStar/audiosilo-server/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  AUDIOSILO_VER=${AUDIOSILO_RELEASE#v} && \
  mkdir -p \
    /app/audiosilo && \
  curl -fsSL -o \
    /tmp/audiosilo.tar.gz \
    "https://github.com/KodeStar/audiosilo-server/releases/download/v${AUDIOSILO_VER}/audiosilo_${AUDIOSILO_VER}_linux_amd64.tar.gz" && \
  tar xzf \
    /tmp/audiosilo.tar.gz -C \
    /app/audiosilo \
    --no-same-owner \
    audiosilo && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8080
VOLUME /config
