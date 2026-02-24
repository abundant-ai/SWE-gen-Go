#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go120_test.go" "prometheus/collectors/go_collector_go120_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_metrics_go120_test.go" "prometheus/go_collector_metrics_go120_test.go"

# Temporarily rename test files that have compilation errors due to bug.patch
# This allows us to compile the package without errors
mv prometheus/go_collector_latest_test.go prometheus/go_collector_latest_test.go.bak 2>/dev/null || true
mv prometheus/collectors/go_collector_latest_test.go prometheus/collectors/go_collector_latest_test.go.bak 2>/dev/null || true

# Run tests for prometheus/collectors package
go test -v ./prometheus/collectors 2>&1
test_status_collectors=$?

# Run tests for prometheus package
go test -v ./prometheus 2>&1
test_status_prometheus=$?

# Restore the renamed files
mv prometheus/go_collector_latest_test.go.bak prometheus/go_collector_latest_test.go 2>/dev/null || true
mv prometheus/collectors/go_collector_latest_test.go.bak prometheus/collectors/go_collector_latest_test.go 2>/dev/null || true

# Overall status: both must pass
if [ $test_status_collectors -eq 0 ] && [ $test_status_prometheus -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
