#!/bin/bash

set -euo pipefail
cd /go/src/github.com/gin-gonic/gin

patch -p1 < /solution/fix.patch

# Rebuild vendor dependencies after fix.patch changes vendor.json
govendor sync
