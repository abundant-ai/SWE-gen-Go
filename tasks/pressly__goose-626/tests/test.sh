#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/provider"
cp "/tests/internal/provider/collect_test.go" "internal/provider/collect_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/provider_test.go" "internal/provider/provider_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/run_test.go" "internal/provider/run_test.go"

# Run tests for the specific package containing the test files
# Use -short flag to skip tests that require Docker
go test -v -short ./internal/provider/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
