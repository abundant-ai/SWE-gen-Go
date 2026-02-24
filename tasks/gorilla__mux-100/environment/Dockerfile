FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.6 (PR #100 is compatible with Go 1.2-1.6)
RUN curl -fsSL https://go.dev/dl/go1.6.4.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Clone repo at HEAD commit (with fix applied) into GOPATH
RUN mkdir -p "${GOPATH}/src/github.com/gorilla" && \
    git clone https://github.com/gorilla/mux.git "${GOPATH}/src/github.com/gorilla/mux" && \
    cd "${GOPATH}/src/github.com/gorilla/mux" && \
    (git fetch --depth 1 origin 98fb535d771e43021d337c156c78ab13d1a7f506 || git fetch --depth 1 origin "+refs/pull/100/head:refs/remotes/origin/pr/100") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gorilla/mux

# Install dependencies (for pre-modules Go)
RUN go get -t -v ./...

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly,
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf .git

WORKDIR ${GOPATH}/src/github.com/gorilla/mux
