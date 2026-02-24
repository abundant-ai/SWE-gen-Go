FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.12 for compatibility with this codebase
RUN curl -fsSL https://go.dev/dl/go1.12.17.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/prometheus/client_golang.git src && \
    cd src && \
    (git fetch --depth 1 origin 63bb61ab5d0cad314b8a6f5de5cab41eaf8a4cf6 || git fetch --depth 1 origin "+refs/pull/295/head:refs/remotes/origin/pr/295") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Create a minimal go.mod to enable module mode for this pre-modules project
RUN go mod init github.com/prometheus/client_golang && \
    go mod edit -replace github.com/prometheus/client_golang=./ && \
    go get github.com/golang/protobuf@v1.2.0 && \
    go get github.com/prometheus/common@v0.0.0-20181126121408-4724e9255275 && \
    go get github.com/prometheus/client_model@fd36f4220a90 && \
    go get github.com/beorn7/perks@3a771d992973 && \
    go get github.com/prometheus/procfs@ae68e2d4c00f && \
    go mod tidy

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
