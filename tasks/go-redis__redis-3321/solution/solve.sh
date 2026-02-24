#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch
# Explicitly remove test file that should be deleted
rm -f gears_commands_test.go
