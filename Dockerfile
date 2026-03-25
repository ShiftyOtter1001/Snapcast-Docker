FROM debian:bookworm-slim

ARG SNAPCAST_VERSION=0.35.0
ARG SNAPWEB_VERSION=0.9.3

RUN apt-get update && apt-get install -y \
    wget \
    ffmpeg \
    libssl3 \
    libavahi-client3 \
    avahi-daemon \
    libasound2 \
    libvorbisidec1 \
    libopus0 \
    python3 \
    python3-websockets \
    && rm -rf /var/lib/apt/lists/*

COPY go-librespot /usr/bin/go-librespot
RUN chmod +x /usr/bin/go-librespot

# Install snapserver
RUN wget -q https://github.com/badaix/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_bookworm.deb \
    && dpkg -i snapserver_${SNAPCAST_VERSION}-1_amd64_bookworm.deb \
    && apt-get install -f -y \
    && rm snapserver_${SNAPCAST_VERSION}-1_amd64_bookworm.deb

# Install snapclient
RUN wget -q https://github.com/badaix/snapcast/releases/download/v${SNAPCAST_VERSION}/snapclient_${SNAPCAST_VERSION}-1_amd64_bookworm.deb \
    && dpkg -i snapclient_${SNAPCAST_VERSION}-1_amd64_bookworm.deb \
    && apt-get install -f -y \
    && rm snapclient_${SNAPCAST_VERSION}-1_amd64_bookworm.deb

# Install snapweb
RUN wget -q https://github.com/badaix/snapweb/releases/download/v${SNAPWEB_VERSION}/snapweb_${SNAPWEB_VERSION}-1_all.deb \
    && dpkg -i snapweb_${SNAPWEB_VERSION}-1_all.deb \
    && rm snapweb_${SNAPWEB_VERSION}-1_all.deb

EXPOSE 1704 1705 1780

CMD ["snapserver", "-c", "/config/snapserver.conf"]
