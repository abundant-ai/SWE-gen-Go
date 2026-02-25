FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.8 (required by go.mod)
RUN curl -fsSL https://go.dev/dl/go1.24.8.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/minio/minio.git src && \
    cd src && \
    (git fetch --depth 1 origin 11699ef6c3eecf0f380c0520baaf0135d0d0476e || git fetch --depth 1 origin "+refs/pull/19763/head:refs/remotes/origin/pr/19763") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set Go environment variables
ENV CGO_ENABLED=0 \
    GO111MODULE=on

# Download Go dependencies
RUN go mod download

# Build MinIO
RUN make build

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (required for Go)
RUN make build

RUN rm -rf /app/src/.git

WORKDIR /app/src
