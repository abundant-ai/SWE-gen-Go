FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (go.mod requires 1.22.1)
RUN curl -fsSL https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/golangci/golangci-lint.git src && \
    cd src && \
    (git fetch --depth 1 origin 64708b84f07b6783399940ff24e08b5d09e41875 || git fetch --depth 1 origin "+refs/pull/4918/head:refs/remotes/origin/pr/4918") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for Go and tests
ENV CGO_ENABLED=1
ENV GOLANGCI_LINT_INSTALLED=true
ENV GL_TEST_RUN=1

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
