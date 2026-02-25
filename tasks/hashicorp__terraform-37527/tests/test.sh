#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/views"
cp "/tests/internal/command/views/hook_json_test.go" "internal/command/views/hook_json_test.go"
mkdir -p "internal/command/views"
cp "/tests/internal/command/views/operation_test.go" "internal/command/views/operation_test.go"

# Run tests for the specific package containing the test files
go test -v ./internal/command/views
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
