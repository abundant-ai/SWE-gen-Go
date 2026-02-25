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
    (git fetch --depth 1 origin 3e883130f430c1a6cbe09394a7060ad04ad46c9e || git fetch --depth 1 origin "+refs/pull/579/head:refs/remotes/origin/pr/579") && \
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
    mkdir -p /go/src/github.com/streadway && \
    mkdir -p /go/src/github.com/nats-io && \
    mkdir -p /go/src/github.com/golang && \
    mkdir -p /go/src/google.golang.org && \
    mkdir -p /go/src/github.com/dgrijalva && \
    mkdir -p /go/src/github.com/opentracing && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src && \
    git clone https://github.com/go-stack/stack /go/src/github.com/go-stack/stack && \
    git clone --branch release-branch.go1.9 https://github.com/golang/net /go/src/golang.org/x/net && \
    git clone https://github.com/golang/crypto /go/src/golang.org/x/crypto && \
    git clone https://github.com/golang/sys /go/src/golang.org/x/sys && \
    git clone https://github.com/ugorji/go /go/src/github.com/ugorji/go && \
    git clone https://github.com/coreos/go-semver /go/src/github.com/coreos/go-semver && \
    git clone --branch v3.2.25 https://github.com/etcd-io/etcd /go/src/github.com/coreos/etcd && \
    ln -s /go/src/github.com/coreos/etcd /go/src/go.etcd.io/etcd && \
    rm -f /go/src/github.com/coreos/etcd/client/keys.generated.go && \
    git clone https://github.com/streadway/amqp /go/src/github.com/streadway/amqp && \
    git clone https://github.com/nats-io/go-nats /go/src/github.com/nats-io/go-nats && \
    git clone https://github.com/nats-io/nuid /go/src/github.com/nats-io/nuid && \
    git clone https://github.com/nats-io/nkeys /go/src/github.com/nats-io/nkeys && \
    git clone https://github.com/nats-io/gnatsd /go/src/github.com/nats-io/gnatsd && \
    cd /go/src/github.com/nats-io/gnatsd && git checkout v1.1.0 && cd /go/src && \
    git clone https://github.com/golang/protobuf /go/src/github.com/golang/protobuf && \
    cd /go/src/github.com/golang/protobuf && git checkout v1.2.0 && cd /go/src && \
    git clone https://github.com/grpc/grpc-go /go/src/google.golang.org/grpc && \
    cd /go/src/google.golang.org/grpc && git checkout v1.5.2 && cd /go/src && \
    git clone https://github.com/googleapis/go-genproto /go/src/google.golang.org/genproto && \
    cd /go/src/google.golang.org/genproto && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/golang/text /go/src/golang.org/x/text && \
    cd /go/src/golang.org/x/text && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    find /go/src/golang.org/x/text -name '*gen*.go' -type f -exec grep -l 'package main' {} \; | xargs rm -f && \
    find /go/src/golang.org/x/text -name 'maketables.go' -delete && \
    find /go/src/golang.org/x/sys -name '*gen*.go' -type f -exec grep -l 'package main' {} \; | xargs rm -f && \
    git clone https://github.com/golang/time /go/src/golang.org/x/time && \
    cd /go/src/golang.org/x/time && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/dgrijalva/jwt-go /go/src/github.com/dgrijalva/jwt-go && \
    cd /go/src/github.com/dgrijalva/jwt-go && git checkout v3.2.0 && cd /go/src && \
    git clone https://github.com/opentracing/opentracing-go /go/src/github.com/opentracing/opentracing-go && \
    cd /go/src/github.com/opentracing/opentracing-go && git checkout v1.0.2 && cd /go/src

# Reset any changes from dependency installation
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
