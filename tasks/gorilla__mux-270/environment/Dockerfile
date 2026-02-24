FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.9 (version used in .travis.yml)
RUN curl -fsSL https://go.dev/dl/go1.9.7.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Clone repo at HEAD commit (with fix applied) into GOPATH
RUN mkdir -p "${GOPATH}/src/github.com/gorilla" && \
    git clone https://github.com/gorilla/mux.git "${GOPATH}/src/github.com/gorilla/mux" && \
    cd "${GOPATH}/src/github.com/gorilla/mux" && \
    (git fetch --depth 1 origin 725a9795fd0d321c1f55f18b276a3b0ed70d7fb9 || git fetch --depth 1 origin "+refs/pull/270/head:refs/remotes/origin/pr/270") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/gorilla/mux

# Install dependencies (for pre-modules Go)
RUN go get -t -v ./...

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf .git

WORKDIR ${GOPATH}/src/github.com/gorilla/mux
