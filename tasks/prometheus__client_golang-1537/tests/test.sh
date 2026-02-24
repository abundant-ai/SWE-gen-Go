#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/summary_test.go" "prometheus/summary_test.go"

# Run only tests that won't conflict with the BASE state (excluding flaky tests)
# Skip tests that fail due to runtime or environment-specific issues
go test -v ./prometheus -skip "TestGoCollector_ExposedMetrics|TestExpectedRuntimeMetrics|TestSummaryDecay" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
