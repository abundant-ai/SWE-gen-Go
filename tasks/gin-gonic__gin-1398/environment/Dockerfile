FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.13 (as specified in go.mod)
RUN curl -fsSL https://go.dev/dl/go1.13.15.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app

# Clone repo into GOPATH structure (required for Go modules with proper import paths)
RUN mkdir -p ${GOPATH}/src/github.com/gin-gonic && \
    git clone https://github.com/gin-gonic/gin.git ${GOPATH}/src/github.com/gin-gonic/gin && \
    cd ${GOPATH}/src/github.com/gin-gonic/gin && \
    (git fetch --depth 1 origin d6f52815a8056e3dfa1dfd19547af2f96a2e156d || git fetch --depth 1 origin "+refs/pull/1398/head:refs/remotes/origin/pr/1398") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin

# Download Go module dependencies
RUN go mod download

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/gin-gonic/gin/.git

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin
