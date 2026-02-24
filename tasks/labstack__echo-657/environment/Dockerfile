FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.7 (required by .travis.yml)
RUN curl -fsSL https://go.dev/dl/go1.7.6.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Set GOPATH for dependency management
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Clone repo into GOPATH/src structure (required by glide)
RUN mkdir -p ${GOPATH}/src/github.com/labstack && \
    git clone https://github.com/labstack/echo.git ${GOPATH}/src/github.com/labstack/echo && \
    cd ${GOPATH}/src/github.com/labstack/echo && \
    (git fetch --depth 1 origin 4d3a267ab3aa184fcc143b4a0ff55e4c3b226890 || git fetch --depth 1 origin "+refs/pull/657/head:refs/remotes/origin/pr/657") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/labstack/echo

# Install glide (Go dependency management tool)
RUN go get -u github.com/Masterminds/glide

# Install dependencies using glide
RUN glide install

# Reset any changes from dependency installation so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/labstack/echo/.git

WORKDIR ${GOPATH}/src/github.com/labstack/echo
