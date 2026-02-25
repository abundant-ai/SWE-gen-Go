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
    (git fetch --depth 1 origin 8317f15f4d926b7214e3906abc06772397c4e596 || git fetch --depth 1 origin "+refs/pull/58/head:refs/remotes/origin/pr/58") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install minimal dependencies needed for log and zipkin tests
RUN mkdir -p /go/src/gopkg.in && \
    git clone https://github.com/go-logfmt/logfmt /go/src/gopkg.in/logfmt.v0 && \
    cd /go/src/gopkg.in/logfmt.v0 && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/gopkg.in/logfmt.v0/.git && \
    git clone https://github.com/go-stack/stack /go/src/gopkg.in/stack.v1 && \
    cd /go/src/gopkg.in/stack.v1 && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/gopkg.in/stack.v1/.git

# Install Apache Thrift and golang.org/x/net for zipkin tests (use 2015 versions compatible with PR #79)
RUN mkdir -p /go/src/github.com/apache && \
    git clone https://github.com/apache/thrift /go/src/github.com/apache/thrift && \
    cd /go/src/github.com/apache/thrift && git checkout c76a9ecdd29ee7c542b276c975c2731687900224 && \
    rm -rf /go/src/github.com/apache/thrift/.git && \
    mkdir -p /go/src/golang.org/x && \
    git clone https://github.com/golang/net /go/src/golang.org/x/net && \
    cd /go/src/golang.org/x/net && git log --until="2015-08-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/golang.org/x/net/.git

# Install circuitbreaker dependencies (2015 era versions compatible with PR #58)
RUN mkdir -p /go/src/github.com/sony && \
    git clone https://github.com/sony/gobreaker /go/src/github.com/sony/gobreaker && \
    cd /go/src/github.com/sony/gobreaker && git log --until="2016-01-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/sony/gobreaker/.git && \
    mkdir -p /go/src/github.com/afex && \
    git clone https://github.com/afex/hystrix-go /go/src/github.com/afex/hystrix-go && \
    cd /go/src/github.com/afex/hystrix-go && git log --until="2016-01-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/afex/hystrix-go/.git && \
    mkdir -p /go/src/github.com/streadway && \
    git clone https://github.com/streadway/handy /go/src/github.com/streadway/handy && \
    cd /go/src/github.com/streadway/handy && git log --until="2016-01-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/streadway/handy/.git

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
