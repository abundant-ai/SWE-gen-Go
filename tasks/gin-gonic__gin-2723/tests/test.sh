#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests in the root package where the test files were modified
# Skip TestContextFormFileFailed17 which is a Go 1.17-specific test that fails on Go 1.23
go test -v -skip=TestContextFormFileFailed17 .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
