#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_test.go" "prometheus/process_collector_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_windows_test.go" "prometheus/process_collector_windows_test.go"

# Run tests for the specific test files in the prometheus package
go test -v ./prometheus -run "^(TestProcessCollector|TestProcessCollectorWindows)" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
