#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/command/e2etest"
cp "/tests/internal/command/e2etest/provider_dev_test.go" "internal/command/e2etest/provider_dev_test.go"

# Run tests for the specific package
go test -v ./internal/command/e2etest
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
