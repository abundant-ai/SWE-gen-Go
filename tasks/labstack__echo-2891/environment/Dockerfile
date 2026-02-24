FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25 (required by go.mod)
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/labstack/echo.git src && \
    cd src && \
    (git fetch --depth 1 origin 48f25a6c16273b2ef34b292c71cfd0593577e5d1 || git fetch --depth 1 origin "+refs/pull/2891/head:refs/remotes/origin/pr/2891") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Go dependencies
RUN go mod download

# Save testdata files that will be deleted by bug.patch but needed for tests
RUN mkdir -p /tmp/testdata && \
    cp -r middleware/testdata /tmp/testdata/ || true

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Restore testdata files so tests can run (they get deleted by bug.patch but aren't re-added by fix.patch)
RUN cp -r /tmp/testdata/testdata middleware/ && rm -rf /tmp/testdata

RUN rm -rf /app/src/.git

WORKDIR /app/src
