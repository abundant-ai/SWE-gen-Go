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
    (git fetch --depth 1 origin dae3ef48b0a68ab9253cbe61ca46a0322a391fff || git fetch --depth 1 origin "+refs/pull/177/head:refs/remotes/origin/pr/177") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install minimal dependencies needed for metrics tests
RUN mkdir -p /go/src/github.com/codahale && \
    git clone https://github.com/codahale/hdrhistogram /go/src/github.com/codahale/hdrhistogram && \
    cd /go/src/github.com/codahale/hdrhistogram && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/codahale/hdrhistogram/.git && \
    mkdir -p /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/client_golang /go/src/github.com/prometheus/client_golang && \
    cd /go/src/github.com/prometheus/client_golang && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/prometheus/client_golang/.git && \
    mkdir -p /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/client_model /go/src/github.com/prometheus/client_model && \
    cd /go/src/github.com/prometheus/client_model && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/prometheus/client_model/.git && \
    git clone https://github.com/prometheus/common /go/src/github.com/prometheus/common && \
    cd /go/src/github.com/prometheus/common && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/prometheus/common/.git && \
    git clone https://github.com/prometheus/procfs /go/src/github.com/prometheus/procfs && \
    cd /go/src/github.com/prometheus/procfs && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/prometheus/procfs/.git && \
    mkdir -p /go/src/github.com/beorn7 && \
    git clone https://github.com/beorn7/perks /go/src/github.com/beorn7/perks && \
    cd /go/src/github.com/beorn7/perks && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/beorn7/perks/.git && \
    mkdir -p /go/src/github.com/matttproud && \
    git clone https://github.com/matttproud/golang_protobuf_extensions /go/src/github.com/matttproud/golang_protobuf_extensions && \
    cd /go/src/github.com/matttproud/golang_protobuf_extensions && git log --until="2018-02-01" --format="%H" -1 | xargs git checkout && \
    rm -rf /go/src/github.com/matttproud/golang_protobuf_extensions/.git && \
    mkdir -p /go/src/github.com/golang && \
    git clone https://github.com/golang/protobuf /go/src/github.com/golang/protobuf && \
    cd /go/src/github.com/golang/protobuf && git checkout v1.2.0 && \
    rm -rf /go/src/github.com/golang/protobuf/.git

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
