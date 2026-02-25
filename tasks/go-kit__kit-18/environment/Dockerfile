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
    (git fetch --depth 1 origin 2e19bd329c1bb3291e6ab9af7a64b8a7b45acad7 || git fetch --depth 1 origin "+refs/pull/18/head:refs/remotes/origin/pr/18") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/peterbourgon/gokit

# statsd package only uses standard library, no external dependencies needed

RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/peterbourgon/gokit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/peterbourgon/gokit /app/src

WORKDIR /go/src/github.com/peterbourgon/gokit
