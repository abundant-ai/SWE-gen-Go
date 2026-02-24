#!/bin/bash

cd /app/src

# Set lower file descriptor limits to match historical test expectations
ulimit -n 4096 2>/dev/null || true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_test.go" "prometheus/go_collector_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_test.go" "prometheus/process_collector_test.go"

# Run tests for the prometheus package
go test -v github.com/prometheus/client_golang/prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
