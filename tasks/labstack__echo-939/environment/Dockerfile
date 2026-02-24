FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.15 (required by go.mod)
RUN curl -fsSL https://go.dev/dl/go1.15.15.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set GOPATH for dependency management (must be set before cloning)
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Clone repo into GOPATH/src structure (required by dep)
RUN mkdir -p ${GOPATH}/src/github.com/labstack && \
    git clone https://github.com/labstack/echo.git ${GOPATH}/src/github.com/labstack/echo && \
    cd ${GOPATH}/src/github.com/labstack/echo && \
    (git fetch --depth 1 origin 5f6c3e4db95caeb13d55edfdf81d004fe7c7ec5a || git fetch --depth 1 origin "+refs/pull/939/head:refs/remotes/origin/pr/939") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/labstack/echo

# Install dep (Go dependency management tool)
RUN curl -fsSL -o /usr/local/bin/dep https://github.com/golang/dep/releases/download/v0.4.1/dep-linux-amd64 && \
    chmod +x /usr/local/bin/dep

# Install dependencies using dep
RUN dep ensure -vendor-only

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/labstack/echo/.git

WORKDIR ${GOPATH}/src/github.com/labstack/echo
