#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "assert"
cp "/tests/assert/assertions_test.go" "assert/assertions_test.go"
mkdir -p "assert"
cp "/tests/assert/forward_assertions_test.go" "assert/forward_assertions_test.go"
mkdir -p "require"
cp "/tests/require/requirements_test.go" "require/requirements_test.go"

# Run tests for the specific packages
go test -v ./assert ./require
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
