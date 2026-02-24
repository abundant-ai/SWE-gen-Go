#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/export_test.go" "internal/pool/export_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"
mkdir -p "."
cp "/tests/options_test.go" "options_test.go"
mkdir -p "."
cp "/tests/sentinel_test.go" "sentinel_test.go"

# Run tests for specific test files and packages
# For root package tests, run the specific test files
# For internal/pool, run the entire package
go test -v ./internal/pool/... && go test -v -run "^(TestOptionsTestSuite|TestSentinelTestSuite)$" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
