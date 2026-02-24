#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent"
cp "/tests/agent/event_endpoint_test.go" "agent/event_endpoint_test.go"

# Run the specific test file for this PR
# Since we're testing event_endpoint_test.go, run tests matching TestEvent or TestUUID
go test -v ./agent -run "^(TestEvent|TestUUID)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
