#!/bin/bash

cd /app/src


# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/group_test.go" "group_test.go"
mkdir -p "middleware"
cp "/tests/middleware/static_test.go" "middleware/static_test.go"

# Run Go tests for the specific test files
go test -v -run "TestGroup_|TestStatic" ./...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
