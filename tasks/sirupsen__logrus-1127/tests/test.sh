#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/example_function_test.go" "example_function_test.go"

# Run the specific test files using go test
# The -v flag shows verbose output for each test
# The -race flag enables the race detector to catch concurrency issues
go test -v -race .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
