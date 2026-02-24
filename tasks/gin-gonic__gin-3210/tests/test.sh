#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/gin_integration_test.go" "gin_integration_test.go"

# Download any new dependencies that HEAD test files need
go mod download

# Run tests for the specific files from this PR
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
