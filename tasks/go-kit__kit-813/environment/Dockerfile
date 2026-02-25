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
    (git fetch --depth 1 origin 272f7b6ce6368fb3683485b76a580b69ad2b46c5 || git fetch --depth 1 origin "+refs/pull/813/head:refs/remotes/origin/pr/813") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install Go dependencies
RUN mkdir -p /go/src/github.com/go-logfmt && \
    mkdir -p /go/src/github.com/openzipkin && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src/github.com/openzipkin && \
    git clone https://github.com/openzipkin/zipkin-go && cd zipkin-go && git checkout v0.1.1 && \
    rm -f propagation/b3/grpc.go propagation/b3/grpc_test.go

# Reset any changes from dependency installation
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
