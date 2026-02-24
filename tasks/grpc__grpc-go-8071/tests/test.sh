#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/leakcheck"
cp "/tests/internal/leakcheck/leakcheck_test.go" "internal/leakcheck/leakcheck_test.go"
mkdir -p "internal/transport"
cp "/tests/internal/transport/transport_test.go" "internal/transport/transport_test.go"

# Run tests on the specific packages
go test -v -timeout 7m ./internal/leakcheck ./internal/transport
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
