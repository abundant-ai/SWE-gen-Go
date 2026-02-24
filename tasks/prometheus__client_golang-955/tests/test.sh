#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_go116_test.go" "prometheus/go_collector_go116_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_go117_test.go" "prometheus/go_collector_go117_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_metrics_go117_test.go" "prometheus/go_collector_metrics_go117_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_test.go" "prometheus/go_collector_test.go"
mkdir -p "prometheus/internal"
cp "/tests/prometheus/internal/go_runtime_metrics_test.go" "prometheus/internal/go_runtime_metrics_test.go"

# Run only the specific tests from the PR test files
go test -v -run '^(TestBatchHistogram|TestExpectedRuntimeMetrics|TestGoCollectorGC|TestGoCollectorGoroutines|TestGoCollectorMemStats|TestGoCollectorRuntimeMetrics|TestMemStatsEquivalence)$' ./prometheus 2>&1
test_status_prometheus=$?

go test -v -run '^TestRuntimeMetricsToProm$' ./prometheus/internal 2>&1
test_status_internal=$?

# Combine the test results
test_status=$((test_status_prometheus + test_status_internal))

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
