#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/benchmark_test.go" "prometheus/benchmark_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/gauge_test.go" "prometheus/gauge_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/http_test.go" "prometheus/promhttp/http_test.go"

# Temporarily rename test files that have compilation errors due to bug.patch
# This allows us to compile the package without errors
mv prometheus/go_collector_latest_test.go prometheus/go_collector_latest_test.go.bak 2>/dev/null || true

# Run only the specific test functions from the PR test files
# Test files: benchmark_test.go, examples_test.go, gauge_test.go
# Only gauge_test.go has Test functions; benchmark_test.go has Benchmark functions; examples_test.go has Example functions
go test -v ./prometheus -run "^(TestGaugeConcurrency|TestGaugeVecConcurrency|TestGaugeFunc|TestGaugeSetCurrentTime)$" 2>&1
test_status_prometheus=$?

# Restore the renamed file
mv prometheus/go_collector_latest_test.go.bak prometheus/go_collector_latest_test.go 2>/dev/null || true

# Run tests for the promhttp package
go test -v ./prometheus/promhttp 2>&1
test_status_promhttp=$?

# Overall status: both must pass
if [ $test_status_prometheus -eq 0 ] && [ $test_status_promhttp -eq 0 ]; then
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
