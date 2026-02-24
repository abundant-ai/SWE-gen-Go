FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24 (matches CI config)
RUN curl -fsSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
# Using "gorm" as directory name so file paths include "gorm/" for test assertions
RUN git clone https://github.com/go-gorm/gorm.git gorm && \
    cd gorm && \
    (git fetch --depth 1 origin a75d7d6b8e38767e0911a200136cb71b080c90e2 || git fetch --depth 1 origin "+refs/pull/7153/head:refs/remotes/origin/pr/7153") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/gorm

# Download dependencies
RUN go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/gorm/.git

WORKDIR /app/gorm
