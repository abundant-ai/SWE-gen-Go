FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (latest dependencies require new stdlib packages)
RUN curl -fsSL https://go.dev/dl/go1.23.5.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# Disable Go modules for pre-modules codebase
ENV GO111MODULE=off
ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"

# Clone repo at HEAD commit (with fix applied) into GOPATH
RUN mkdir -p /go/src/github.com/go-kit && \
    git clone https://github.com/go-kit/kit.git /go/src/github.com/go-kit/kit && \
    cd /go/src/github.com/go-kit/kit && \
    (git fetch --depth 1 origin 970b0d804079d422e7cb222e765eba68789e2e90 || git fetch --depth 1 origin "+refs/pull/850/head:refs/remotes/origin/pr/850") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install Go dependencies for transport/amqp package
# Clone dependencies into GOPATH manually at versions compatible with 2019 codebase
RUN mkdir -p /go/src/github.com/go-logfmt && \
    mkdir -p /go/src/github.com/streadway && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src/github.com/streadway && \
    git clone https://github.com/streadway/amqp && cd amqp && git checkout 75d898a42a940fbc854dfd1a4199eabdc00cf024

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
