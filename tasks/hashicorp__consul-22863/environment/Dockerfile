FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.1 (required by go.mod)
RUN curl -fsSL https://go.dev/dl/go1.25.1.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/hashicorp/consul.git src && \
    cd src && \
    (git fetch --depth 1 origin 6de177e379d6f7db03a7a5f16c8d6a69655a69bc || git fetch --depth 1 origin "+refs/pull/22863/head:refs/remotes/origin/pr/22863") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for tests
ENV CI=true

# Download Go dependencies
RUN go mod download

# Build the project to verify everything compiles
RUN go build ./...

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Go is a compiled language)
RUN go build ./...

RUN rm -rf /app/src/.git

WORKDIR /app/src
