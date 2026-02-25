#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.sum" "zapgrpc/internal/test/go.sum"

# Run tests in the internal/pool package
go test -v ./internal/pool
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
