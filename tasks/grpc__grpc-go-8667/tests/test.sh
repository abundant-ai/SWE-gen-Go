#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "mem"
cp "/tests/mem/buffer_slice_test.go" "mem/buffer_slice_test.go"

# Run the specific test package for this PR
go test -v -timeout 7m ./mem
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
