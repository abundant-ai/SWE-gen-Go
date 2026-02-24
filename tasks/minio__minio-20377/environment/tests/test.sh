#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/store"
cp "/tests/internal/store/batch_test.go" "internal/store/batch_test.go"
mkdir -p "internal/store"
cp "/tests/internal/store/queuestore_test.go" "internal/store/queuestore_test.go"
mkdir -p "internal/store"
cp "/tests/internal/store/store_test.go" "internal/store/store_test.go"

# Run tests from the modified test files in internal/store package
go test -v -timeout 10m ./internal/store
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
