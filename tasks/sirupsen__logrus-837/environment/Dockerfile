FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.16 (matching CI configuration)
RUN curl -fsSL https://go.dev/dl/go1.16.15.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/sirupsen/logrus.git src && \
    cd src && \
    (git fetch --depth 1 origin a13c5db57c07b6f81ed4ad333c219966151ec30a || git fetch --depth 1 origin "+refs/pull/837/head:refs/remotes/origin/pr/837") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install Go dependencies
RUN go mod download

# Reset to ensure bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Go test compiles on the fly, no rebuild needed after patching

RUN rm -rf /app/src/.git

WORKDIR /app/src
