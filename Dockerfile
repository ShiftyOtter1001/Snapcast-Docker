FROM debian:bookworm-slim

ARG SNAPCAST_VERSION=0.34.0
ARG GOLIBRESPOT_VERSION=0.7.1

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    jq \
    ffmpeg \
    libssl3 \
    libavahi-client3 \
    avahi-daemon \
    && rm -rf /var/lib/apt/lists/*

# Install go-librespot - use GitHub API to find the correct amd64 asset URL
RUN DOWNLOAD_URL=$(curl -s https://api.github.com/repos/devgianlu/go-librespot/releases/tags/v${GOLIBRESPOT_VERSION} \
    | jq -r '.assets[] | select(.name | test("linux.*amd64|amd64.*linux")) | .browser_download_url' \
    | head -1) \
    && echo "Downloading go-librespot from: $DOWNLOAD_URL" \
    && wget -q "$DOWNLOAD_URL" -O go-librespot.tar.gz \
    && tar -xzf go-librespot.tar.gz \
    && find . -name 'go-librespot' -type f -exec mv {} /usr/bin/go-librespot \; \
    && chmod +x /usr/bin/go-librespot \
    && rm -f go-librespot.tar.gz

# Install snapserver from official GitHub releases
RUN wget -q https://github.com/snapcast/snapcast/releases/download/v${SNAPCAST_VERSION}/snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb \
    && dpkg -i snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb \
    && apt-get install -f -y \
    && rm snapserver_${SNAPCAST_VERSION}-1_amd64_debian_bookworm.deb

EXPOSE 1704 1705 1780

CMD ["snapserver", "-c", "/config/snapserver.conf"]
