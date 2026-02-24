#!/bin/bash

set -euo pipefail
cd /go/src/github.com/gin-gonic/gin

patch -p1 < /solution/fix.patch

# Download new dependencies added by fix.patch
go mod download
