FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.9 (matches Travis CI config which tests 1.6-1.9)
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
    (git fetch --depth 1 origin e8d927a48891554c0f8d67a86d71997d4f2140c3 || git fetch --depth 1 origin "+refs/pull/1047/head:refs/remotes/origin/pr/1047") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin

# Install govendor and sync dependencies (this PR uses govendor, not go modules)
RUN go get -u github.com/kardianos/govendor && \
    govendor sync

# Reset any changes from dependency installation so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/gin-gonic/gin/.git

WORKDIR ${GOPATH}/src/github.com/gin-gonic/gin
