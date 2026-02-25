#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/field_test.go" "field_test.go"
mkdir -p "internal/stacktrace"
cp "/tests/internal/stacktrace/stack_test.go" "internal/stacktrace/stack_test.go"

# Run tests for the packages containing the PR test files
overall_status=0

# Main package test (field_test.go)
go test -v . || overall_status=1

# internal/stacktrace package test (stack_test.go)
go test -v ./internal/stacktrace || overall_status=1

test_status=$overall_status

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
