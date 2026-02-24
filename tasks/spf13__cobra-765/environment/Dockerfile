FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

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
    (git fetch --depth 1 origin 720c3c2ffa9784cf96bb691970805f11c3296386 || git fetch --depth 1 origin "+refs/pull/765/head:refs/remotes/origin/pr/765") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# This is a pre-Go modules project, set up GOPATH structure
ENV PATH="${GOPATH}/bin:${PATH}"

# Create the GOPATH structure and symlink cobra into it for GOPATH-style imports
RUN mkdir -p /go/src/github.com/spf13 && \
    ln -s /app/src /go/src/github.com/spf13/cobra

# Install dependencies - pflag is the main external dependency
RUN go get -d github.com/spf13/pflag

WORKDIR /app/src

# Apply bug.patch to revert to buggy state
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go is compiled but tests are compiled on-the-fly by `go test`, so no rebuild needed

RUN rm -rf /app/src/.git

WORKDIR /app/src
