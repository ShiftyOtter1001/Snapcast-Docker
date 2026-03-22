FROM debian:bookworm-slim AS snapserver

ARG SNAPCAST_VERSION=0.34.0

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/snapcast/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb


# Pull go-librespot prebuilt binary
FROM ghcr.io/devgianlu/go-librespot:latest AS golibrespot


# Final image
FROM debian:bookworm-slim

ARG SNAPCAST_VERSION=0.34.0

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libssl3 \
    libavahi-client3 \
    avahi-daemon \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy snapserver deb from build stage and install it
COPY --from=snapserver /snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb /tmp/
RUN dpkg -i /tmp/snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb \
    && apt-get install -f -y \
    && rm /tmp/snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb

# Copy go-librespot binary from its image
COPY --from=golibrespot /go-librespot /usr/bin/go-librespot

EXPOSE 1704 1705 1780

CMD ["snapserver", "-c", "/config/snapserver.conf"]
