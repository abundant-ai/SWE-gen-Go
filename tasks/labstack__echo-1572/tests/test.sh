#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"
mkdir -p "middleware"
cp "/tests/middleware/recover_test.go" "middleware/recover_test.go"

# Run Go tests for the specific test files: echo_test.go (root package) and middleware/recover_test.go
go test -v . ./middleware -run "TestEcho|Recover"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
