#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/sqladapter"
cp "/tests/internal/sqladapter/store_test.go" "internal/sqladapter/store_test.go"
mkdir -p "."
cp "/tests/provider_options_test.go" "provider_options_test.go"

# Run tests for the specific packages touched by this PR
# Use -short flag to skip tests that require Docker
go test -v -short ./internal/sqladapter .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
