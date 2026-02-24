FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.4 (matching CI configuration from .travis.yml)
RUN curl -fsSL https://go.dev/dl/go1.4.3.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GO111MODULE=off
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Set up GOPATH structure for pre-module Go project
RUN mkdir -p /go/src/github.com/sirupsen

WORKDIR /go/src/github.com/sirupsen

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/sirupsen/logrus.git logrus && \
    cd logrus && \
    (git fetch --depth 1 origin a2f80bd9c0ccfd63d3826dc68fcafa094833132e || git fetch --depth 1 origin "+refs/pull/247/head:refs/remotes/origin/pr/247") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

# Create symlink for case-insensitive import path (Sirupsen vs sirupsen)
# Historical: the repo moved from github.com/Sirupsen/logrus to github.com/sirupsen/logrus
RUN mkdir -p /go/src/github.com/Sirupsen && \
    ln -s /go/src/github.com/sirupsen/logrus /go/src/github.com/Sirupsen/logrus

WORKDIR /go/src/github.com/sirupsen/logrus

# Install dependencies compatible with Go 1.4
RUN go get -d github.com/stretchr/testify/assert 2>&1 || true
RUN go get -d github.com/tobi/airbrake-go 2>&1 || true
# Downgrade dependencies to versions compatible with Go 1.4 (from late 2015)
RUN cd /go/src/github.com/stretchr/testify && \
    git checkout v1.0
RUN cd /go/src/github.com/tobi/airbrake-go && \
    git checkout $(git rev-list -n 1 --before="2015-10-06" master)

# Reset to ensure bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go test compiles on the fly, no rebuild needed after patching

RUN rm -rf /go/src/github.com/sirupsen/logrus/.git

WORKDIR /go/src/github.com/sirupsen/logrus
