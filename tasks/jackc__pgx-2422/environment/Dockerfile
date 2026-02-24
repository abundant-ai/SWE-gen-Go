FROM ubuntu:24.04

# Base system packages (common to all languages)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    patch \
    build-essential \
    wget \
    postgresql \
    postgresql-contrib \
    lsb-release \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.0 (as specified in go.mod)
RUN wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz && \
    rm go1.24.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

WORKDIR /app

# Clone repo at HEAD commit (with fix applied)
RUN git clone https://github.com/jackc/pgx.git src && \
    cd src && \
    (git fetch --depth 1 origin c3a17505ff2d016e41002629f57da8bf6859e762 || git fetch --depth 1 origin "+refs/pull/2422/head:refs/remotes/origin/pr/2422") && \
    git checkout --detach FETCH_HEAD && \
    git submodule update --init --recursive

WORKDIR /app/src

# Download Go dependencies
RUN go mod download

# Set up PostgreSQL for testing
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER root WITH SUPERUSER PASSWORD 'secret';" && \
    createdb -O root pgx_test && \
    psql pgx_test -f testsetup/postgresql_setup.sql
USER root

# If install/build steps touched tracked files, reset them so bug.patch applies cleanly
RUN git reset --hard

# Apply bug.patch to revert to buggy state (BASE)
COPY bug.patch /tmp/bug.patch
RUN patch -p1 < /tmp/bug.patch && rm /tmp/bug.patch

RUN rm -rf /app/src/.git

WORKDIR /app/src
