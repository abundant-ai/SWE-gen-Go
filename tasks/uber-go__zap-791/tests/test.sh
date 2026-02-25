#!/bin/bash

cd /app/zap

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/config_test.go" "config_test.go"

# Run tests from modified packages
# Tests for PR #791 (config_test.go changes):
# - Root package: config_test.go tests

# Run config tests from root package
go test -v . -run "TestConfig"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
