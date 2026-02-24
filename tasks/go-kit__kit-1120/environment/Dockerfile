FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.17
RUN curl -fsSL https://go.dev/dl/go1.17.13.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/go-kit/kit.git src && \
    cd src && \
    (git fetch --depth 1 origin dc986ba5b188af849f7c69a46f605297a66a70e1 || git fetch --depth 1 origin "+refs/pull/1120/head:refs/remotes/origin/pr/1120") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set GOFLAGS to match CI environment
ENV GOFLAGS="-mod=readonly"

# Download Go dependencies
RUN go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
