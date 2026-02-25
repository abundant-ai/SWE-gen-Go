FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.12 (matches 2019 timeframe of this commit)
RUN curl -fsSL https://go.dev/dl/go1.12.4.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/go-gorm/gorm.git src && \
    cd src && \
    (git fetch --depth 1 origin 5c9ba54b65e3a9d8ad439acdd2768b00b0366148 || git fetch --depth 1 origin "+refs/pull/2142/head:refs/remotes/origin/pr/2142") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Set environment to allow tests to download dependencies without checksum verification
ENV GOSUMDB=off

RUN rm -rf /app/src/.git

WORKDIR /app/src
