#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/jsonformat"
cp "/tests/internal/command/jsonformat/plan_test.go" "internal/command/jsonformat/plan_test.go"

# Run tests for the specific package containing the test files
go test -v ./internal/command/jsonformat
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
