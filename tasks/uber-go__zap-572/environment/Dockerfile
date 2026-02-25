FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.10 (version used in Travis CI for this project)
RUN curl -fsSL https://go.dev/dl/go1.10.8.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/uber-go/zap.git src && \
    cd src && \
    (git fetch --depth 1 origin 3c295665a7fa7e7b9eb601cc51de021e826434e3 || git fetch --depth 1 origin "+refs/pull/572/head:refs/remotes/origin/pr/572") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set GOPATH mode since this version doesn't use modules
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Create GOPATH structure and move repo to correct location
RUN mkdir -p /go/src/go.uber.org && \
    mv /app/src /go/src/go.uber.org/zap && \
    ln -s /go/src/go.uber.org/zap /app/src

# Install dependencies manually with correct versions from glide.lock
WORKDIR /go/src/go.uber.org/zap
# Install atomic at the pinned version
RUN mkdir -p /go/src/go.uber.org && \
    cd /go/src/go.uber.org && \
    git clone https://github.com/uber-go/atomic.git && \
    cd atomic && git checkout 4e336646b2ef9fc6e47be8e21594178f98e5ebcf
# Install multierr at the pinned version
RUN cd /go/src/go.uber.org && \
    git clone https://github.com/uber-go/multierr.git && \
    cd multierr && git checkout 3c4937480c32f4c13a875a1829af76c98ca3d40a
# Install testify
RUN mkdir -p /go/src/github.com/stretchr && \
    cd /go/src/github.com/stretchr && \
    git clone https://github.com/stretchr/testify.git && \
    cd testify && git checkout f35b8ab0b5a2cef36673838d662e249dd9c94686
# Install pkg/errors
RUN mkdir -p /go/src/github.com/pkg && \
    cd /go/src/github.com/pkg && \
    git clone https://github.com/pkg/errors.git && \
    cd errors && git checkout 645ef00459ed84a119197bfb8d8205042c6df63d

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
