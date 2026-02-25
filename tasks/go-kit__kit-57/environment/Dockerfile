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

# Clone repo at HEAD commit (with fix applied) into GOPATH
RUN mkdir -p /go/src/github.com/go-kit && \
    git clone https://github.com/go-kit/kit.git /go/src/github.com/go-kit/kit && \
    cd /go/src/github.com/go-kit/kit && \
    (git fetch --depth 1 origin 57c36a7486a84df99e97a90285575ee77c3ec041 || git fetch --depth 1 origin "+refs/pull/57/head:refs/remotes/origin/pr/57") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install minimal dependencies needed for ratelimit tests
RUN mkdir -p /go/src/golang.org/x && \
    git clone https://github.com/golang/net /go/src/golang.org/x/net && \
    cd /go/src/golang.org/x/net && git log --until="2015-08-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/golang.org/x/net/.git && \
    mkdir -p /go/src/github.com/juju && \
    git clone https://github.com/juju/ratelimit /go/src/github.com/juju/ratelimit && \
    cd /go/src/github.com/juju/ratelimit && git log --until="2015-08-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/juju/ratelimit/.git

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
