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
    (git fetch --depth 1 origin 1513e76fea395e59b2d269160361a3675aeb9d93 || git fetch --depth 1 origin "+refs/pull/1939/head:refs/remotes/origin/pr/1939") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Install dependencies using GOPATH (pre-modules GORM)
ENV GOPATH=/root/go
RUN go get -v github.com/jinzhu/inflection github.com/erikstmartin/go-testdb || true
RUN go get -v github.com/jinzhu/now || true
# Install database drivers compatible with Go 1.12
RUN mkdir -p /root/go/src/github.com/lib && \
    cd /root/go/src/github.com/lib && \
    git clone https://github.com/lib/pq.git && \
    cd pq && git checkout v1.2.0 && go install . || true
RUN mkdir -p /root/go/src/github.com/go-sql-driver && \
    cd /root/go/src/github.com/go-sql-driver && \
    git clone https://github.com/go-sql-driver/mysql.git && \
    cd mysql && git checkout v1.4.1 && go install . || true
RUN mkdir -p /root/go/src/github.com/mattn && \
    cd /root/go/src/github.com/mattn && \
    git clone https://github.com/mattn/go-sqlite3.git && \
    cd go-sqlite3 && git checkout v1.11.0 && go install . || true

# Symlink the source to GOPATH so tests can import it
RUN mkdir -p /root/go/src/github.com/jinzhu && \
    ln -s /app/src /root/go/src/github.com/jinzhu/gorm

RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
