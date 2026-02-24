#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/lang"
cp "/tests/internal/lang/function_results_test.go" "internal/lang/function_results_test.go"

# Run tests for the specific package containing the test file
go test -v ./internal/lang
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
