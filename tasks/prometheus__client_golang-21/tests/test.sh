#!/bin/bash

cd /app/src

# Set lower file descriptor limits to match historical test expectations
ulimit -n 4096 2>/dev/null || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "extraction"
cp "/tests/extraction/discriminator_test.go" "extraction/discriminator_test.go"
mkdir -p "extraction"
cp "/tests/extraction/metricfamilyprocessor_test.go" "extraction/metricfamilyprocessor_test.go"

# Run tests for the extraction package affected by this PR
go test -v github.com/prometheus/client_golang/extraction 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
