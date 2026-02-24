#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"
mkdir -p "middleware"
cp "/tests/middleware/decompress_test.go" "middleware/decompress_test.go"

# Run Go tests for the specific test files from this PR
go test -v . -run "TestContext" && \
go test -v ./middleware -run "TestDecompress"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
