FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.9 (required for this old version of go-chi/chi)
RUN curl -fsSL https://go.dev/dl/go1.9.7.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/app

WORKDIR /app

# Clone repo at HEAD commit (with fix applied) into GOPATH structure
RUN mkdir -p /app/src/github.com/go-chi && \
    git clone https://github.com/go-chi/chi.git /app/src/github.com/go-chi/chi && \
    cd /app/src/github.com/go-chi/chi && \
    (git fetch --depth 1 origin 6ca1005b79b8827a2b0fc9115d21fad1616e7847 || git fetch --depth 1 origin "+refs/pull/75/head:refs/remotes/origin/pr/75") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src/github.com/go-chi/chi

# Create symlink for old import path (pressly/chi -> go-chi/chi)
# This commit still uses the old "github.com/pressly/chi" import path
RUN mkdir -p /app/src/github.com/pressly && \
    ln -s /app/src/github.com/go-chi/chi /app/src/github.com/pressly/chi

# Install dependencies (GOPATH mode - clone into GOPATH)
# Use older versions compatible with Go 1.9
RUN mkdir -p /app/src/golang.org/x && \
    git clone https://go.googlesource.com/net /app/src/golang.org/x/net && \
    cd /app/src/golang.org/x/net && git checkout release-branch.go1.9 && \
    cd /app && \
    git clone https://go.googlesource.com/text /app/src/golang.org/x/text && \
    cd /app/src/golang.org/x/text && git checkout $(git log --before="2017-09-01" --format="%H" -n 1)

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/github.com/go-chi/chi/.git

WORKDIR /app/src/github.com/go-chi/chi
