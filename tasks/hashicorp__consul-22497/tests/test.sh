#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "command/debug"
cp "/tests/command/debug/debug_test.go" "command/debug/debug_test.go"

# Run the specific tests for the PR
go test -v -timeout=10m ./command/debug
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
