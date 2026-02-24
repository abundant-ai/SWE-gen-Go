FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install additional system packages (libffi for Go compatibility)
RUN apt-get update && apt-get install -y \
    libffi8 \
    && rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/lib/x86_64-linux-gnu/libffi.so.8 /usr/lib/x86_64-linux-gnu/libffi.so.6

# Install Go runtime (using Go 1.11 for pre-modules GOPATH compatibility)
RUN curl -fsSL https://go.dev/dl/go1.11.13.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/spf13/cobra.git src && \
    cd src && \
    (git fetch --depth 1 origin b4087da7eb1bf3822d8413008dbd4c3c6c3c5f2d || git fetch --depth 1 origin "+refs/pull/149/head:refs/remotes/origin/pr/149") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# This is a pre-Go modules project, set up GOPATH structure
ENV PATH="${GOPATH}/bin:${PATH}"

# Create the GOPATH structure and symlink cobra into it for GOPATH-style imports
RUN mkdir -p /go/src/github.com/spf13 && \
    ln -s /app/src /go/src/github.com/spf13/cobra

# Install dependencies - pflag is the main dependency, plus doc packages
# Install blackfriday v1 (not v2, which requires Go modules)
# Pin pflag to Sept 2015 commit for compatibility with error message format
RUN mkdir -p /go/src/github.com/spf13 && \
    cd /go/src/github.com/spf13 && \
    git clone https://github.com/spf13/pflag.git && \
    cd pflag && \
    git checkout b084184666e02084b8ccb9b704bf0d79c466eb1d && \
    go get -d github.com/inconshreveable/mousetrap && \
    go get -d gopkg.in/yaml.v2 && \
    go get -d github.com/russross/blackfriday && \
    mkdir -p /go/src/github.com/cpuguy83 && \
    cd /go/src/github.com/cpuguy83 && \
    git clone https://github.com/cpuguy83/go-md2man.git && \
    cd go-md2man && \
    git checkout v1.0.10

WORKDIR /app/src

# Install shellcheck for bash completion testing
RUN mkdir -p /usr/local/bin && \
    curl -Lso /usr/local/bin/shellcheck https://github.com/caarlos0/shellcheck-docker/releases/download/v0.4.3/shellcheck && \
    chmod +x /usr/local/bin/shellcheck

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go is compiled but tests are compiled on-the-fly by `go test`, so no rebuild needed

RUN rm -rf /app/src/.git

WORKDIR /app/src
