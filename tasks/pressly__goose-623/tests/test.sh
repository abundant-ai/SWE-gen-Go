#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "database"
cp "/tests/database/store_test.go" "database/store_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/collect_test.go" "internal/provider/collect_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/provider_test.go" "internal/provider/provider_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/run_test.go" "internal/provider/run_test.go"

# Run tests for the specific packages touched by this PR
# Use -short flag to skip tests that require Docker
go test -v -short ./database ./internal/provider
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
