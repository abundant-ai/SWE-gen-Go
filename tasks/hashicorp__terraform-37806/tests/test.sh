#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/junit"
cp "/tests/internal/command/junit/junit_test.go" "internal/command/junit/junit_test.go"

# Run tests for the specific package containing the test file
go test -v ./internal/command/junit
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
