FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 (required by package.json engines field)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Enable Corepack for Yarn
RUN corepack enable

# Install Chrome for Ember tests
RUN curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb && \
    apt-get update && apt-get install -y /tmp/chrome.deb && \
    rm /tmp/chrome.deb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/hashicorp/consul.git src && \
    cd src && \
    (git fetch --depth 1 origin 6fba004a725911ee4195b49e06c2a62d4648e4eb || git fetch --depth 1 origin "+refs/pull/22815/head:refs/remotes/origin/pr/22815") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for tests
ENV CI=true
ENV CONSUL_NSPACES_ENABLED=0

# Install Yarn dependencies
RUN cd ui && yarn install && cd ..

# Build the Ember UI for testing
RUN cd ui/packages/consul-ui && make build-ci && cd ../../..

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Ember/TypeScript needs rebuild)
RUN cd ui/packages/consul-ui && make build-ci && cd ../../..

RUN rm -rf /app/src/.git

WORKDIR /app/src
