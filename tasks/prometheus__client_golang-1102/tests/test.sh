#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_latest_test.go" "prometheus/collectors/go_collector_latest_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_latest_test.go" "prometheus/go_collector_latest_test.go"

# Run the specific tests from the PR test files
go test -v ./prometheus/collectors -run "." ./prometheus -run "." 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
