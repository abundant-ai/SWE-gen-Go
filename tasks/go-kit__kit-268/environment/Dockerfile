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
    (git fetch --depth 1 origin 59e076e942f411ebda69168b098a8f5187277b8e || git fetch --depth 1 origin "+refs/pull/268/head:refs/remotes/origin/pr/268") && \
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
    mkdir -p /go/src/github.com/hudl && \
    mkdir -p /go/src/github.com/samuel && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src && \
    git clone https://github.com/go-stack/stack /go/src/github.com/go-stack/stack && \
    git clone --branch release-branch.go1.9 https://github.com/golang/net /go/src/golang.org/x/net && \
    git clone https://github.com/golang/crypto /go/src/golang.org/x/crypto && \
    git clone https://github.com/golang/sys /go/src/golang.org/x/sys && \
    git clone https://github.com/ugorji/go /go/src/github.com/ugorji/go && \
    cd /go/src/github.com/ugorji/go && git log --until="2017-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
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
    cd /go/src/github.com/opentracing/opentracing-go && git checkout 93ccd1549c8630b063582e7ea2e087f862113809 && cd /go/src && \
    git clone https://github.com/hudl/fargo /go/src/github.com/hudl/fargo && \
    cd /go/src/github.com/hudl/fargo && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/samuel/go-zookeeper /go/src/github.com/samuel/go-zookeeper && \
    cd /go/src/github.com/samuel/go-zookeeper && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/cenkalti/backoff /go/src/github.com/cenkalti/backoff && \
    cd /go/src/github.com/cenkalti/backoff && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/clbanning/x2j /go/src/github.com/clbanning/x2j && \
    cd /go/src/github.com/clbanning/x2j && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/franela/goreq /go/src/github.com/franela/goreq && \
    cd /go/src/github.com/franela/goreq && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/miekg/dns /go/src/github.com/miekg/dns && \
    cd /go/src/github.com/miekg/dns && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/op/go-logging /go/src/github.com/op/go-logging && \
    cd /go/src/github.com/op/go-logging && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://gopkg.in/gcfg.v1 /go/src/gopkg.in/gcfg.v1 && \
    cd /go/src/gopkg.in/gcfg.v1 && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://gopkg.in/warnings.v0 /go/src/gopkg.in/warnings.v0 && \
    cd /go/src/gopkg.in/warnings.v0 && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/VividCortex/gohistogram /go/src/github.com/VividCortex/gohistogram && \
    cd /go/src/github.com/VividCortex/gohistogram && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/aws/aws-sdk-go /go/src/github.com/aws/aws-sdk-go && \
    cd /go/src/github.com/aws/aws-sdk-go && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/go-ini/ini /go/src/github.com/go-ini/ini && \
    cd /go/src/github.com/go-ini/ini && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/jmespath/go-jmespath /go/src/github.com/jmespath/go-jmespath && \
    cd /go/src/github.com/jmespath/go-jmespath && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    mkdir -p /go/src/github.com/influxdata && \
    mkdir -p /go/src/github.com/performancecopilot && \
    mkdir -p /go/src/github.com/prometheus && \
    git clone https://github.com/influxdata/influxdb /go/src/github.com/influxdata/influxdb && \
    cd /go/src/github.com/influxdata/influxdb && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/performancecopilot/speed /go/src/github.com/performancecopilot/speed && \
    cd /go/src/github.com/performancecopilot/speed && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/prometheus/client_golang /go/src/github.com/prometheus/client_golang && \
    cd /go/src/github.com/prometheus/client_golang && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/prometheus/client_model /go/src/github.com/prometheus/client_model && \
    cd /go/src/github.com/prometheus/client_model && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/prometheus/common /go/src/github.com/prometheus/common && \
    cd /go/src/github.com/prometheus/common && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/prometheus/procfs /go/src/github.com/prometheus/procfs && \
    cd /go/src/github.com/prometheus/procfs && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/beorn7/perks /go/src/github.com/beorn7/perks && \
    cd /go/src/github.com/beorn7/perks && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    git clone https://github.com/matttproud/golang_protobuf_extensions /go/src/github.com/matttproud/golang_protobuf_extensions && \
    cd /go/src/github.com/matttproud/golang_protobuf_extensions && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    mkdir -p /go/src/github.com/hashicorp && \
    git clone https://github.com/hashicorp/consul /go/src/github.com/hashicorp/consul && \
    cd /go/src/github.com/hashicorp/consul && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src && \
    mkdir -p /go/src/github.com/codahale && \
    git clone https://github.com/codahale/hdrhistogram /go/src/github.com/codahale/hdrhistogram && \
    cd /go/src/github.com/codahale/hdrhistogram && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && cd /go/src

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
