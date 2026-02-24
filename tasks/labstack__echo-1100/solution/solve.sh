#!/bin/bash

set -euo pipefail
cd /go/src/github.com/labstack/echo

# Apply the patch (this will modify files but not delete them)
patch -p1 < /solution/fix.patch

# Manually delete the version-specific files that should be removed
rm -f echo_go1.8.go echo_go1.8_test.go util_go17.go util_go18.go
