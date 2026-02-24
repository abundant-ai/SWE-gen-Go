FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.11 (this PR predates Go modules)
RUN curl -fsSL https://go.dev/dl/go1.11.13.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app

# Clone repo into GOPATH structure (required for pre-modules Go)
RUN mkdir -p ${GOPATH}/src/github.com/gin-gonic && \
    git clone https://github.com/gin-gonic/gin.git ${GOPATH}/src/github.com/gin-gonic/gin && \
    cd ${GOPATH}/src/github.com/gin-gonic/gin && \
    (git fetch --depth 1 origin 84522a901854bd21515878c49154862ce424df57 || git fetch --depth 1 origin "+refs/pull/1504/head:refs/remotes/origin/pr/1504") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin

# Install govendor for dependency management (pre-modules era)
RUN go get -u github.com/kardianos/govendor

# Sync vendor dependencies
RUN govendor sync || true

# Reset tracked files so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/gin-gonic/gin/.git

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin
