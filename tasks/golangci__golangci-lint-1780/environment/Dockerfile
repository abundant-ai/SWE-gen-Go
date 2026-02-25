FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.17 (matching CI environment)
RUN curl -fsSL https://go.dev/dl/go1.17.13.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/golangci/golangci-lint.git src && \
    cd src && \
    (git fetch --depth 1 origin 59fb9c5e805307645ce20bdcf3c2169f1487561a || git fetch --depth 1 origin "+refs/pull/1780/head:refs/remotes/origin/pr/1780") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Go and tests
ENV CGO_ENABLED=1
ENV GOLANGCI_LINT_INSTALLED=true

# Download Go dependencies
RUN go mod download

# Download dependencies for scripts/gen_github_action_config (separate module)
RUN cd scripts/gen_github_action_config && go mod download && cd ../..

# Build golangci-lint binary (required by test suite)
RUN go build -o golangci-lint ./cmd/golangci-lint

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Re-download dependencies (in case bug.patch changed go.mod)
RUN go mod download

# Re-download dependencies for scripts/gen_github_action_config (in case bug.patch changed it)
RUN cd scripts/gen_github_action_config && go mod download && cd ../..

# Rebuild golangci-lint binary after applying bug.patch
RUN go build -o golangci-lint ./cmd/golangci-lint

RUN rm -rf /app/src/.git

WORKDIR /app/src
