#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/pattern_test.go" "pattern_test.go"

# Run the specific test from pattern_test.go
go test -v -run TestPattern .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
