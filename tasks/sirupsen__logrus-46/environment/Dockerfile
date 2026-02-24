FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.17 (supports GOPATH mode, modern build tags, and has modern standard library)
RUN curl -fsSL https://go.dev/dl/go1.17.13.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create GOPATH directory structure (note: original repo uses capital S)
RUN mkdir -p ${GOPATH}/src/github.com/Sirupsen

# Clone repo into GOPATH (required for pre-module Go projects)
# Note: Using Sirupsen (capital S) to match import paths in code
RUN git clone https://github.com/sirupsen/logrus.git ${GOPATH}/src/github.com/Sirupsen/logrus && \
    cd ${GOPATH}/src/github.com/Sirupsen/logrus && \
    (git fetch --depth 1 origin 2a6183b10643fb31bd0a15314b4987517cc3eb07 || git fetch --depth 1 origin "+refs/pull/46/head:refs/remotes/origin/pr/46") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/Sirupsen/logrus

# Create symlink for harbor compatibility
RUN mkdir -p /app && ln -s ${GOPATH}/src/github.com/Sirupsen/logrus /app/src

# Set environment variables for Go (disable modules to use GOPATH mode)
ENV CGO_ENABLED=0
ENV GO111MODULE=off

# Install dependencies (as per Travis CI config)
RUN go get -t ./...

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

# Rebuild after applying bug.patch (Go needs recompilation)
RUN go get -t ./...

RUN rm -rf ${GOPATH}/src/github.com/Sirupsen/logrus/.git

WORKDIR /app/src
