#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/status"
cp "/tests/internal/status/status_test.go" "internal/status/status_test.go"
mkdir -p "status"
cp "/tests/status/status_test.go" "status/status_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/status/... ./status/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
