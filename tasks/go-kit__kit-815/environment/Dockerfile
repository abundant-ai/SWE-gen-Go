FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (latest dependencies require new stdlib packages)
RUN curl -fsSL https://go.dev/dl/go1.23.5.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

# Disable Go modules for pre-modules codebase
ENV GO111MODULE=off
ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"

# Clone repo at HEAD commit (with fix applied) into GOPATH
RUN mkdir -p /go/src/github.com/go-kit && \
    git clone https://github.com/go-kit/kit.git /go/src/github.com/go-kit/kit && \
    cd /go/src/github.com/go-kit/kit && \
    (git fetch --depth 1 origin 1a313386a870a505534d47b3eb1a253eadb595b0 || git fetch --depth 1 origin "+refs/pull/815/head:refs/remotes/origin/pr/815") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /go/src/github.com/go-kit/kit

# Install Go dependencies for transport/awslambda package
# Clone dependencies into GOPATH manually at versions compatible with 2019 codebase
RUN mkdir -p /go/src/github.com/go-logfmt && \
    mkdir -p /go/src/github.com/aws && \
    git clone https://github.com/go-logfmt/logfmt /go/src/github.com/go-logfmt/logfmt && \
    cd /go/src/github.com/go-logfmt/logfmt && git checkout v0.3.0 && \
    cd /go/src/github.com/aws && \
    git clone https://github.com/aws/aws-lambda-go && cd aws-lambda-go && git checkout v1.6.0

# Reset any changes from dependency installation
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /go/src/github.com/go-kit/kit/.git

# Create symlink for Harbor Oracle agent compatibility
RUN mkdir -p /app && ln -s /go/src/github.com/go-kit/kit /app/src

WORKDIR /go/src/github.com/go-kit/kit
