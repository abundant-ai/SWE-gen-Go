FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 (required by latest afero)
RUN curl -fsSL https://go.dev/dl/go1.23.0.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
ENV PATH="/usr/local/go/bin:${PATH}"

# Set up GOPATH for pre-modules Go project
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"
WORKDIR ${GOPATH}/src/github.com/spf13

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/spf13/viper.git viper && \
    cd viper && \
    (git fetch --depth 1 origin 41f829b2c9ecf78bcc45a9c18cd9afe1051d86a5 || git fetch --depth 1 origin "+refs/pull/415/head:refs/remotes/origin/pr/415") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR ${GOPATH}/src/github.com/spf13/viper

# Create minimal go.mod for compatibility with modern Go and download dependencies
RUN echo "module github.com/spf13/viper" > go.mod && \
    echo "" >> go.mod && \
    echo "go 1.23" >> go.mod && \
    go get -d .

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf ${GOPATH}/src/github.com/spf13/viper/.git

WORKDIR ${GOPATH}/src/github.com/spf13/viper
