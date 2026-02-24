FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go runtime
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/spf13/cobra.git src && \
    cd src && \
    (git fetch --depth 1 origin b23cee0b5e2b652d416f80387752360049246253 || git fetch --depth 1 origin "+refs/pull/894/head:refs/remotes/origin/pr/894") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

ENV GO111MODULE=on

# Install dependencies
RUN go mod download

# Reset any changes from dependency installation before applying bug.patch
RUN git reset --hard

# Apply bug.patch to revert to buggy state
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go is compiled but tests are compiled on-the-fly by `go test`, so no rebuild needed

RUN rm -rf /app/src/.git

WORKDIR /app/src
