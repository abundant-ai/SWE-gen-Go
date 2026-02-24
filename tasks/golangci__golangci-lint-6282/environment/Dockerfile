FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25 (required by go.mod: go 1.24.0, but CI uses 1.25)
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/golangci/golangci-lint.git src && \
    cd src && \
    (git fetch --depth 1 origin 2a51eb0be2832f7e706706b8e38fe4150268b493 || git fetch --depth 1 origin "+refs/pull/6282/head:refs/remotes/origin/pr/6282") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Go and tests
ENV CGO_ENABLED=1
ENV GOLANGCI_LINT_INSTALLED=true
ENV GL_TEST_RUN=1

# Download Go dependencies
RUN go mod download

# Build golangci-lint binary (required by test suite)
RUN go build -o golangci-lint ./cmd/golangci-lint

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-download dependencies to get the downgraded godoc-lint version (v0.10.2)
RUN go mod download

# Rebuild golangci-lint binary after applying bug.patch
RUN go build -o golangci-lint ./cmd/golangci-lint

RUN rm -rf /app/src/.git

WORKDIR /app/src
