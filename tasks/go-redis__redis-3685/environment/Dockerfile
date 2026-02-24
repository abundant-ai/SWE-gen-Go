FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Redis server for tests
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list && \
    apt-get update && \
    apt-get install -y redis-server redis-tools && \
    rm -rf /var/lib/apt/lists/*

# Install Go (version 1.21+ required per go.mod)
RUN curl -fsSL https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/redis/go-redis.git src && \
    cd src && \
    (git fetch --depth 1 origin 14e0e4788a23133c6f74f403c22133c30965ab9f || git fetch --depth 1 origin "+refs/pull/3685/head:refs/remotes/origin/pr/3685") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for tests
ENV RCE_DOCKER=true
ENV RE_CLUSTER=false
ENV REDIS_VERSION=8.6

# Download Go dependencies
RUN go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
