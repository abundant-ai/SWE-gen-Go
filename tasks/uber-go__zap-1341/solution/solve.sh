#!/bin/bash

set -euo pipefail
cd /app/src

# Remove files that were moved from root to internal/stacktrace by the fix
rm -f stacktrace.go stacktrace_test.go

patch -p1 < /solution/fix.patch
