#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/dbstats_collector_test.go" "prometheus/collectors/dbstats_collector_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_latest_test.go" "prometheus/collectors/go_collector_latest_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_test.go" "prometheus/process_collector_test.go"

# Run tests for the specific packages, excluding flaky tests
# Package: prometheus/collectors
go test -v ./prometheus/collectors 2>&1
collectors_status=$?

# Package: prometheus (has TestProcessCollector)
# Skip TestSummaryDecay as it's flaky and not related to this PR
go test -v -run '^TestProcessCollector$|^TestNewPidFileFn$' ./prometheus 2>&1
prometheus_status=$?

# Combine exit codes - fail if any test failed
if [ $collectors_status -ne 0 ] || [ $prometheus_status -ne 0 ]; then
  test_status=1
else
  test_status=0
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
