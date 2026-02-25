#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/ztest"
cp "/tests/internal/ztest/clock_test.go" "internal/ztest/clock_test.go"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.sum" "zapgrpc/internal/test/go.sum"

# Run tests for internal/ztest package (contains clock_test.go)
go test -v ./internal/ztest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
