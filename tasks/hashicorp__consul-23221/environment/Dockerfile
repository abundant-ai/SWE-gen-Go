FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.7
RUN curl -fsSL https://go.dev/dl/go1.25.7.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/hashicorp/consul.git src && \
    cd src && \
    (git fetch --depth 1 origin e2fff81186cbf1edd61c98715a3c9c1befba8ddc || git fetch --depth 1 origin "+refs/pull/23221/head:refs/remotes/origin/pr/23221") && \
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

# Re-download dependencies after patching (in case go.mod was changed)
RUN go mod download

RUN rm -rf /app/src/.git

WORKDIR /app/src
