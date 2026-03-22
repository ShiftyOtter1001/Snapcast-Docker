FROM debian:bookworm-slim

ARG SNAPCAST_VERSION=0.34.0
ARG SNAPWEB_VERSION=0.9.3

# Install base dependencies + ffmpeg
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    ffmpeg \
    libssl3 \
    libavahi-client3 \
    avahi-daemon \
    build-essential \
    libasound2-dev \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Install librespot via cargo (no prebuilt debian package exists)
RUN cargo install librespot \
    && mv /root/.cargo/bin/librespot /usr/bin/librespot

# Install snapserver from official GitHub releases
RUN wget -q https://github.com/snapcast/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb \
    && dpkg -i snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb \
    && apt-get install -f -y \
    && rm snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb

# Install snapweb from official GitHub releases
RUN wget -q https://github.com/snapcast/snapweb/releases/download/v${SNAPWEB_VERSION}/snapweb_${SNAPWEB_VERSION}-1_all.deb \
    && dpkg -i snapweb_${SNAPWEB_VERSION}-1_all.deb \
    && rm snapweb_${SNAPWEB_VERSION}-1_all.deb

EXPOSE 1704 1705 1780

CMD ["snapserver", "-c", "/config/snapserver.conf"]
