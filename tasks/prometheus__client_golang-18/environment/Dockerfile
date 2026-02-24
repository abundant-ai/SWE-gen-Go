FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.4 for compatibility with this codebase
RUN curl -fsSL https://go.dev/dl/go1.4.3.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/prometheus/client_golang.git src && \
    cd src && \
    (git fetch --depth 1 origin 85899b3f4a9e5f089b41ac9a5ecf19c80c622fed || git fetch --depth 1 origin "+refs/pull/18/head:refs/remotes/origin/pr/18") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set GOPATH for pre-modules codebase
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH

# Set up GOPATH structure for the project
RUN mkdir -p /go/src/github.com/prometheus && \
    ln -s /app/src /go/src/github.com/prometheus/client_golang

# Install dependencies - use compatible versions for Go 1.4
ENV GO111MODULE=off
# Install protobuf at old Google Code import path
RUN mkdir -p /go/src/code.google.com/p && \
    cd /go/src/code.google.com/p && \
    git clone https://github.com/golang/protobuf.git goprotobuf && \
    cd goprotobuf && \
    git reset --hard v1.2.0 && \
    cd /app/src

# Also install at new GitHub path for dependencies that expect it there
RUN mkdir -p /go/src/github.com/golang && \
    cd /go/src/github.com/golang && \
    git clone https://github.com/golang/protobuf.git && \
    cd protobuf && \
    git reset --hard v1.2.0 && \
    cd /app/src

RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/client_model.git && \
    cd client_model && \
    git reset --hard 14fe0d1b01d4d5fc031dd4bec1823bd3ebbe8016 && \
    cd /app/src

RUN mkdir -p /go/src/github.com/matttproud && \
    cd /go/src/github.com/matttproud && \
    git clone https://github.com/matttproud/golang_protobuf_extensions.git && \
    cd golang_protobuf_extensions && \
    git reset --hard ba7d65ac66e9 && \
    cd /app/src

RUN mkdir -p /go/src/github.com/matttproud && \
    cd /go/src/github.com/matttproud && \
    git clone https://github.com/matttproud/gocheck.git && \
    cd gocheck && \
    git reset --hard HEAD && \
    cd /app/src

RUN mkdir -p /go/src/github.com/beorn7 && \
    cd /go/src/github.com/beorn7 && \
    git clone https://github.com/beorn7/perks.git && \
    cd perks && \
    git reset --hard 3a771d992973f24aa725d07868b467d1ddfceafb && \
    cd /app/src

RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/procfs.git && \
    cd procfs && \
    git reset --hard 40f013a808ec4fa79def444a1a56de4d1727efcb && \
    cd /app/src

# Install prometheus/prometheus for test dependencies
RUN mkdir -p /go/src/github.com/prometheus && \
    cd /go/src/github.com/prometheus && \
    git clone https://github.com/prometheus/prometheus.git && \
    cd prometheus && \
    git log --until="2015-02-20" --format="%H" -1 | xargs git reset --hard && \
    cd /app/src

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
