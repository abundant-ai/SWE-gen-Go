#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/communicator/ssh"
cp "/tests/internal/communicator/ssh/communicator_test.go" "internal/communicator/ssh/communicator_test.go"

# Run tests for the specific package containing the test file
go test -v ./internal/communicator/ssh
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
