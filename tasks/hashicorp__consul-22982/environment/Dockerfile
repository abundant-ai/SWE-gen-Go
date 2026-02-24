FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome for Ember tests (required by testem)
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20 (required by ui/packages/consul-ui/package.json engines field)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Enable corepack for pnpm support
RUN corepack enable

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/hashicorp/consul.git src && \
    cd src && \
    (git fetch --depth 1 origin 6a0d08947966a1eb002c3fdcbe7d2052dc9b3634 || git fetch --depth 1 origin "+refs/pull/22982/head:refs/remotes/origin/pr/22982") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Set environment variables for tests
ENV CI=true

# Install UI dependencies using pnpm
WORKDIR /app/src/ui
RUN pnpm install --frozen-lockfile

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
WORKDIR /app/src
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Do NOT build the UI here - it will be built in test.sh after copying the HEAD test file
# This avoids needing to rebuild during test execution (which can run out of memory)

# Do not remove .git directory - Ember tests require it
WORKDIR /app/src
