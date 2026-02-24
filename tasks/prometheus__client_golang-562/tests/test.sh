#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "api/prometheus/v1"
cp "/tests/api/prometheus/v1/api_test.go" "api/prometheus/v1/api_test.go"

# Run tests for the specific package containing the test file
go test -v ./api/prometheus/v1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
