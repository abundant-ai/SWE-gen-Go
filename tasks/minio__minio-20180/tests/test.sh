#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/generic-handlers_test.go" "cmd/generic-handlers_test.go"
mkdir -p "cmd"
cp "/tests/cmd/lock-rest-client_test.go" "cmd/lock-rest-client_test.go"
mkdir -p "internal/grid"
cp "/tests/internal/grid/grid_test.go" "internal/grid/grid_test.go"

# Run tests from the modified test files in cmd and internal/grid packages
go test -v -timeout 10m ./cmd ./internal/grid
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
