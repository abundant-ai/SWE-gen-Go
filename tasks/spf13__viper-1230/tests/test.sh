#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/fs_test.go" "fs_test.go"
mkdir -p "."
cp "/tests/viper_test.go" "viper_test.go"

# Run tests from the current package with race detector
# Testing the whole package since Go tests need all dependencies
go test -v -race .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
