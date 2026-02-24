#!/bin/bash

cd /go/src/github.com/labstack/echo

# Install dependencies manually with versions compatible with Go 1.7
# Use specific commits from around 2015
mkdir -p ${GOPATH}/src/github.com/labstack
if [ ! -d "${GOPATH}/src/github.com/labstack/gommon" ]; then
  git clone https://github.com/labstack/gommon.git ${GOPATH}/src/github.com/labstack/gommon 2>&1 | head -5 || true
  cd ${GOPATH}/src/github.com/labstack/gommon
  git checkout $(git rev-list -n 1 --first-parent --before="2016-01-01" HEAD 2>/dev/null || git rev-list -n 1 HEAD) 2>&1 | head -5 || true
fi

mkdir -p ${GOPATH}/src/github.com/stretchr
if [ ! -d "${GOPATH}/src/github.com/stretchr/testify" ]; then
  git clone https://github.com/stretchr/testify.git ${GOPATH}/src/github.com/stretchr/testify 2>&1 | head -5 || true
  cd ${GOPATH}/src/github.com/stretchr/testify
  # Use v1.1.3 (Dec 2015) which works with Go 1.7
  git checkout v1.1.3 2>&1 | head -5 || true
fi

# Install transitive dependencies for gommon (colorable and isatty)
mkdir -p ${GOPATH}/src/github.com/mattn
if [ ! -d "${GOPATH}/src/github.com/mattn/go-colorable" ]; then
  git clone https://github.com/mattn/go-colorable.git ${GOPATH}/src/github.com/mattn/go-colorable 2>&1 | head -5 || true
  cd ${GOPATH}/src/github.com/mattn/go-colorable
  git checkout $(git rev-list -n 1 --first-parent --before="2016-01-01" HEAD 2>/dev/null || git rev-list -n 1 HEAD) 2>&1 | head -5 || true
fi

if [ ! -d "${GOPATH}/src/github.com/mattn/go-isatty" ]; then
  git clone https://github.com/mattn/go-isatty.git ${GOPATH}/src/github.com/mattn/go-isatty 2>&1 | head -5 || true
  cd ${GOPATH}/src/github.com/mattn/go-isatty
  git checkout $(git rev-list -n 1 --first-parent --before="2016-01-01" HEAD 2>/dev/null || git rev-list -n 1 HEAD) 2>&1 | head -5 || true
fi

# Install golang.org/x/net packages
mkdir -p ${GOPATH}/src/golang.org/x
if [ ! -d "${GOPATH}/src/golang.org/x/net" ]; then
  git clone https://go.googlesource.com/net ${GOPATH}/src/golang.org/x/net 2>&1 | head -5 || true
  cd ${GOPATH}/src/golang.org/x/net
  git checkout $(git rev-list -n 1 --first-parent --before="2016-01-01" HEAD 2>/dev/null || git rev-list -n 1 HEAD) 2>&1 | head -5 || true
fi

# Install bradfitz/http2 package
mkdir -p ${GOPATH}/src/github.com/bradfitz
if [ ! -d "${GOPATH}/src/github.com/bradfitz/http2" ]; then
  git clone https://github.com/bradfitz/http2.git ${GOPATH}/src/github.com/bradfitz/http2 2>&1 | head -5 || true
  cd ${GOPATH}/src/github.com/bradfitz/http2
  git checkout $(git rev-list -n 1 --first-parent --before="2016-01-01" HEAD 2>/dev/null || git rev-list -n 1 HEAD) 2>&1 | head -5 || true
fi

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/router_test.go" "router_test.go"

# Run tests for router_test.go
go test -v . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
