FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.10 (matching CI configuration from .travis.yml)
RUN curl -fsSL https://go.dev/dl/go1.10.8.linux-amd64.tar.gz | tar -C /usr/local -xzf -
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
    (git fetch --depth 1 origin 725f3be1995f9bb46c7aa065ff200bef3a346cee || git fetch --depth 1 origin "+refs/pull/781/head:refs/remotes/origin/pr/781") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/sirupsen/logrus

# Install dependencies compatible with Go 1.10
RUN go get -d github.com/stretchr/testify/assert 2>&1 || true
RUN go get -d gopkg.in/gemnasium/logrus-airbrake-hook.v2 2>&1 || true
RUN go get -d golang.org/x/sys/unix 2>&1 || true
RUN go get -d golang.org/x/crypto/ssh/terminal 2>&1 || true
# Downgrade dependencies to versions compatible with Go 1.10 (from early 2018)
RUN cd /go/src/github.com/stretchr/testify && \
    git checkout v1.2.2
RUN cd /go/src/golang.org/x/sys && \
    git checkout $(git rev-list -n 1 --before="2018-03-01" master) && \
    find . -name "mk*.go" -delete
RUN cd /go/src/golang.org/x/crypto && \
    git checkout $(git rev-list -n 1 --before="2018-03-01" master)

# Reset to ensure bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go test compiles on the fly, no rebuild needed after patching

RUN rm -rf /go/src/github.com/sirupsen/logrus/.git

WORKDIR /go/src/github.com/sirupsen/logrus
