# Dockerfile
FROM rust:latest as builder

# Build arguments
ARG ANKI_VERSION

# Install build dependencies
RUN apt-get update && apt-get install -y protobuf-compiler musl-tools \
    && rm -rf /var/lib/apt/lists/* \
    && rustup target add x86_64-unknown-linux-musl

# Build anki-sync-server with musl
WORKDIR /usr/src/anki
RUN cargo install --git https://github.com/ankitects/anki.git \
    --branch main \
    --tag ${ANKI_VERSION} \
    --target x86_64-unknown-linux-musl \
    anki-sync-server \
    && strip /usr/local/cargo/bin/anki-sync-server

FROM scratch

# Add labels
LABEL maintainer="Anki Sync Server Docker Maintainers"
LABEL version="${ANKI_VERSION}"
LABEL description="Anki Sync Server Docker Image"
LABEL org.opencontainers.image.source="https://github.com/kenyon-wong/anki-sync-server-docker.git"

# Setup runtime environment
ENV DEFAULT_SYNC_BASE=/opt/anki.d/sync.d

# Create sync directory
WORKDIR ${DEFAULT_SYNC_BASE}

# Copy anki-sync-server binary
COPY --from=builder /usr/local/cargo/bin/anki-sync-server /usr/local/bin/anki-sync-server

CMD ["anki-sync-server"]
