#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/gin_integration_test.go" "gin_integration_test.go"
mkdir -p "."
cp "/tests/tree_test.go" "tree_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests in the root package where gin_integration_test.go and tree_test.go were modified
# Skip TestContextFormFileFailed17 which is a Go 1.17-specific test that fails on Go 1.23
go test -v -skip=TestContextFormFileFailed17 .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
