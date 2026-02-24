#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/picker_wrapper_test.go" "picker_wrapper_test.go"
mkdir -p "test"
cp "/tests/end2end_test.go" "test/end2end_test.go"
mkdir -p "test"
cp "/tests/retry_test.go" "test/retry_test.go"
mkdir -p "test"
cp "/tests/stats_test.go" "test/stats_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m . ./test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
