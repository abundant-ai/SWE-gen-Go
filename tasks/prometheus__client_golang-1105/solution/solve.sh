#!/bin/bash

set -euo pipefail
cd /app/src

patch -p1 < /solution/fix.patch

# After fixing the generator, copy the correctly generated test file from solution directory
cp /solution/go_collector_metrics_go119_test.go prometheus/go_collector_metrics_go119_test.go
