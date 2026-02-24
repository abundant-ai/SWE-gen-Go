#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/example_clustermanager_test.go" "prometheus/example_clustermanager_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/wrap_test.go" "prometheus/wrap_test.go"

# Run tests for the package containing the test files
go test -v ./prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
