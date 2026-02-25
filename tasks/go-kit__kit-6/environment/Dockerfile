FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.10 (compatible with etcd v3.2.25 era)
RUN curl -fsSL https://go.dev/dl/go1.10.8.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# Disable Go modules for pre-modules codebase
ENV GO111MODULE=off
ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"

# Clone repo at HEAD commit (with fix applied) into GOPATH at old package path
RUN mkdir -p /go/src/github.com/peterbourgon && \
    git clone https://github.com/go-kit/kit.git /go/src/github.com/peterbourgon/gokit && \
    cd /go/src/github.com/peterbourgon/gokit && \
    (git fetch --depth 1 origin 4928fe6b444b27b24a1db2747a2c35e76aa3a6da || git fetch --depth 1 origin "+refs/pull/6/head:refs/remotes/origin/pr/6") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/peterbourgon/gokit

# Install external dependencies for metrics packages (compatible versions for Go 1.10)
# hdrhistogram
RUN mkdir -p /go/src/github.com/codahale && \
    cd /go/src/github.com/codahale && \
    git clone https://github.com/codahale/hdrhistogram.git && \
    cd hdrhistogram && \
    git checkout 3a0bb77429bd

# prometheus client_golang v0.8.0 (last version compatible with Go 1.10)
RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/client_golang.git && \
    cd client_golang && \
    git checkout v0.8.0

# prometheus client_model (required by client_golang v0.8.0)
RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/client_model.git && \
    cd client_model && \
    git checkout fa8ad6fec33561be4280a8f0514318c79d7f6cb6

# prometheus common (required by client_golang v0.8.0)
RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/common.git && \
    cd common && \
    git checkout d811d2e9bf898806ecfb6ef6296774b13ffc314c

# prometheus procfs (required by client_golang v0.8.0)
RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/procfs.git && \
    cd procfs && \
    git checkout 1dc9a6cbc91aacc3e8b2d63db4d2e957a5394ac4

# golang protobuf (required by prometheus)
RUN mkdir -p /go/src/github.com/golang && \
    cd /go/src/github.com/golang && \
    git clone https://github.com/golang/protobuf.git && \
    cd protobuf && \
    git checkout 1643683e1b54a9e88ad26d98f81400c8c9d9f4f9

# matttproud golang_protobuf_extensions (required by prometheus)
RUN mkdir -p /go/src/github.com/matttproud && \
    cd /go/src/github.com/matttproud && \
    git clone https://github.com/matttproud/golang_protobuf_extensions.git && \
    cd golang_protobuf_extensions && \
    git checkout c12348ce28de40eed0136aa2b644d0ee0650e56c

# beorn7 perks (required by prometheus)
RUN mkdir -p /go/src/github.com/beorn7 && \
    cd /go/src/github.com/beorn7 && \
    git clone https://github.com/beorn7/perks.git && \
    cd perks && \
    git checkout 4c0e84591b9aa9e6dcfdf3e020114cd81f89d5f9

RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/peterbourgon/gokit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/peterbourgon/gokit /app/src

WORKDIR /go/src/github.com/peterbourgon/gokit
