FROM alpine:3.19 as builder
RUN apk add --no-cache \
      git \
      ldc \
      make \
      gcc \
      musl-dev \
      sqlite-dev \
      curl-dev \
      pkgconfig && \
    git clone -b v1.1.0-rc1 https://github.com/bpozdena/OneDriveGUI.git /tmp/OneDriveGUI && \
    git clone https://github.com/abraunegg/onedrive.git /tmp/onedrive && \
    cd /tmp/onedrive && \
    git fetch origin pull/2661/head:pr2661 && \
    git checkout pr2661 && \
    ./configure DC=/usr/bin/ldmd2 && \
    make && \
    make install

FROM jlesage/baseimage-gui:alpine-3.19-v4
ENV APP_NAME="OneDriveGUI" \
    HOME="/root" \
    S6_KILL_GRACETIME=8000
COPY --from=builder /tmp/onedrive/onedrive /usr/bin/ 
COPY --from=builder /tmp/OneDriveGUI/ $HOME/OneDriveGUI
RUN apk add --no-cache \
      ca-certificates \
      xterm \
      wget \
      openbox \
      ldc-runtime \
      libdrm \
      sqlite-dev \
      curl-dev \
      py3-pyside6 \
      py3-requests \
      wqy-zenhei &&\
    rm -rf /tmp/* /var/cache/apk/*
COPY --chmod=777 rootfs/ / 
VOLUME ["$HOME/data", "$HOME/.config"]