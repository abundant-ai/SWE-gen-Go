#!/bin/bash

cd /app/src


# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"
mkdir -p "."
cp "/tests/response_test.go" "response_test.go"

# Run Go tests for the specific test files
go test -v -run "TestContext|TestResponse" ./...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
