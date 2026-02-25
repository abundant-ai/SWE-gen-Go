#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/globals_test.go" "globals_test.go"

# Run tests for the root package (where globals_test.go is located)
# Use -short flag to skip tests that require Docker
go test -v -short .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
