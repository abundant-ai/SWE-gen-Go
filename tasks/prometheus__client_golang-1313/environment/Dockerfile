FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.21.0 (required for Go 1.21 support PR - use initial release for metric compatibility)
RUN curl -fsSL https://go.dev/dl/go1.21.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/prometheus/client_golang.git src && \
    cd src && \
    (git fetch --depth 1 origin e5639d1dcb98e3f1027e110d11ab9eda54e36f34 || git fetch --depth 1 origin "+refs/pull/1313/head:refs/remotes/origin/pr/1313") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Go dependencies for main module
RUN go mod download

# Download Go dependencies for tutorial/whatsup submodule
RUN cd tutorial/whatsup && go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Convert CRLF to LF in workflow files to match patch expectations
RUN find .github/workflows -type f -name "*.yml" -exec dos2unix {} \;

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
