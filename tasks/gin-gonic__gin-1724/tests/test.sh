#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"

# Download any new dependencies that HEAD test files need
go mod tidy && go mod download

# Run tests for the root package (logger_test.go)
# Use -mod=mod to ignore vendor directory inconsistencies
go test -v -mod=mod .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
