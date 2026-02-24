#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"

# Run tests for the prometheus package containing the test files
go test -v ./prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
