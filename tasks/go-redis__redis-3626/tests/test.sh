#!/bin/bash

cd /app/src

# Set environment variables for tests
export RCE_DOCKER=true
export RE_CLUSTER=false
export REDIS_VERSION=8.6

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/double_freeturn_simple_test.go" "internal/pool/double_freeturn_simple_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/double_freeturn_test.go" "internal/pool/double_freeturn_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"

# Run tests for the internal/pool package with shorter timeout
# The test has a deadlock bug that will hang for 10m by default, so we use 5m timeout
go test -v -timeout=5m ./internal/pool
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
