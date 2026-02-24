#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/e2etest"
cp "/tests/internal/command/e2etest/pluggable_state_store_test.go" "internal/command/e2etest/pluggable_state_store_test.go"
mkdir -p "internal/command/e2etest"
cp "/tests/internal/command/e2etest/primary_test.go" "internal/command/e2etest/primary_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/workspace_command_test.go" "internal/command/workspace_command_test.go"

# Run tests for the specific packages containing the test files
go test -v ./internal/command/e2etest ./internal/command
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
