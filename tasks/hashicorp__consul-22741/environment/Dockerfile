FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.0 (required by go.mod)
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/hashicorp/consul.git src && \
    cd src && \
    (git fetch --depth 1 origin d2962d227f56be6d38cb6a4d4890c8dfd54546c8 || git fetch --depth 1 origin "+refs/pull/22741/head:refs/remotes/origin/pr/22741") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for tests
ENV CI=true
ENV GOFLAGS="-buildvcs=false"

# Download Go dependencies
RUN go mod download

# Build the project
RUN go build ./...

# Reset any tracked file modifications from build
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Go is a compiled language)
RUN go build ./...

RUN rm -rf /app/src/.git

WORKDIR /app/src
