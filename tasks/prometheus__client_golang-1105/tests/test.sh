#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_latest_test.go" "prometheus/go_collector_latest_test.go"
# Note: go_collector_metrics_go119_test.go is NOT copied here - only Oracle's solve.sh provides it

# Run TestExpectedRuntimeMetrics - it will fail for NOP (missing expectedRuntimeMetrics) but pass for Oracle
go test -v ./prometheus -run "^TestExpectedRuntimeMetrics$" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
