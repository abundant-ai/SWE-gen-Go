#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/stacks/stackruntime/internal/stackeval"
cp "/tests/internal/stacks/stackruntime/internal/stackeval/planning_test.go" "internal/stacks/stackruntime/internal/stackeval/planning_test.go"

# Run tests for the specific package
go test -v ./internal/stacks/stackruntime/internal/stackeval
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
