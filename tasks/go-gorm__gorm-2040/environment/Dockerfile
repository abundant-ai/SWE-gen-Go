FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.12 (matches 2019 timeframe of this commit)
RUN curl -fsSL https://go.dev/dl/go1.12.4.linux-amd64.tar.gz | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/go-gorm/gorm.git src && \
    cd src && \
    (git fetch --depth 1 origin 4ab3223f0368db09457bb67d5332f442ccc9fb4b || git fetch --depth 1 origin "+refs/pull/2040/head:refs/remotes/origin/pr/2040") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies using GOPATH (pre-modules GORM)
ENV GOPATH=/root/go
RUN go get -v github.com/jinzhu/inflection github.com/erikstmartin/go-testdb || true
RUN go get -v github.com/lib/pq github.com/jinzhu/now || true

# Symlink the source to GOPATH so tests can import it
RUN mkdir -p /root/go/src/github.com/jinzhu && \
    ln -s /app/src /root/go/src/github.com/jinzhu/gorm

RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
