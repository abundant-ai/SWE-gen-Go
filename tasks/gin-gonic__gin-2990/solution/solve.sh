#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# Update go.mod and go.sum after changing Go version requirement
go mod tidy
