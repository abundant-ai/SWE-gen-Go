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
    (git fetch --depth 1 origin 9f6be30a00bcb58da8380ace600ac6d10f8f7662 || git fetch --depth 1 origin "+refs/pull/754/head:refs/remotes/origin/pr/754") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install Go dependencies
RUN mkdir -p /go/src/github.com/go-logfmt && \
    mkdir -p /go/src/github.com/go-stack && \
    mkdir -p /go/src/golang.org/x && \
    mkdir -p /go/src/github.com/coreos && \
    mkdir -p /go/src/github.com/ugorji && \
    mkdir -p /go/src/go.etcd.io && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src && \
    git clone https://github.com/go-stack/stack /go/src/github.com/go-stack/stack && \
    git clone https://github.com/golang/net /go/src/golang.org/x/net && \
    git clone https://github.com/ugorji/go /go/src/github.com/ugorji/go && \
    git clone https://github.com/coreos/go-semver /go/src/github.com/coreos/go-semver && \
    git clone --branch v3.2.25 https://github.com/etcd-io/etcd /go/src/github.com/coreos/etcd && \
    ln -s /go/src/github.com/coreos/etcd /go/src/go.etcd.io/etcd && \
    rm -f /go/src/github.com/coreos/etcd/client/keys.generated.go

# Reset any changes from dependency installation
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
