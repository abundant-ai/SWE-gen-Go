FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.0 (go.mod requires go 1.24.0 minimum)
RUN curl -fsSL https://go.dev/dl/go1.26.0.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/grpc/grpc-go.git src && \
    cd src && \
    (git fetch --depth 1 origin 5bfda4556148e534fd5d2dc5fcb4229c39d93084 || git fetch --depth 1 origin "+refs/pull/8624/head:refs/remotes/origin/pr/8624") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Go module dependencies
RUN go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# No rebuild needed for Go - tests compile on demand

RUN rm -rf /app/src/.git

WORKDIR /app/src
