FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.9 (matches Travis CI config which tests 1.6-1.8)
RUN curl -fsSL https://go.dev/dl/go1.9.7.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

WORKDIR /app

# Clone repo into GOPATH structure (required for proper import paths)
RUN mkdir -p ${GOPATH}/src/github.com/gin-gonic && \
    git clone https://github.com/gin-gonic/gin.git ${GOPATH}/src/github.com/gin-gonic/gin && \
    cd ${GOPATH}/src/github.com/gin-gonic/gin && \
    (git fetch --depth 1 origin 5dafc0cffdc4d62dcd4f8ffc46880018ecdc0388 || git fetch --depth 1 origin "+refs/pull/810/head:refs/remotes/origin/pr/810") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin

# Install key dependencies at specific older versions compatible with Go 1.9
RUN cd ${GOPATH}/src && \
    git clone https://github.com/stretchr/testify.git github.com/stretchr/testify && \
    cd github.com/stretchr/testify && git checkout 976c720a22c8eb4eb6a0b4348ad85ad12491a506

RUN cd ${GOPATH}/src && \
    git clone https://github.com/golang/protobuf.git github.com/golang/protobuf && \
    cd github.com/golang/protobuf && git checkout 5a0f697c9ed9d68fef0116532c6e05cfeae00e55

RUN cd ${GOPATH}/src && \
    mkdir -p github.com/mattn && \
    git clone https://github.com/mattn/go-isatty.git github.com/mattn/go-isatty && \
    cd github.com/mattn/go-isatty && git checkout 57fdcb988a5c543893cc61bce354a6e24ab70022

RUN cd ${GOPATH}/src && \
    mkdir -p gopkg.in/gin-contrib && \
    git clone https://github.com/gin-contrib/sse.git gopkg.in/gin-contrib/sse.v0 && \
    cd gopkg.in/gin-contrib/sse.v0 && git checkout 22d885f9ecc78bf4ee5d72b937e4bbcdc58e8cae

RUN go get -d github.com/manucorporat/sse || true
RUN go get -d golang.org/x/net/context || true
RUN go get -d gopkg.in/go-playground/validator.v8 || true
RUN go get -d gopkg.in/yaml.v2 || true

# Reset any changes from dependency installation so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/gin-gonic/gin/.git

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin
