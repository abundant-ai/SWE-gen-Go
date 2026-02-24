#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "credentials/alts/internal/conn"
cp "/tests/credentials/alts/internal/conn/record_test.go" "credentials/alts/internal/conn/record_test.go"

# Run the specific test package for this PR
go test -v -timeout 7m ./credentials/alts/internal/conn/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
