#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/getproviders/reattach"
cp "/tests/internal/getproviders/reattach/reattach_test.go" "internal/getproviders/reattach/reattach_test.go"

# Run tests for the specific package containing the test file
go test -v ./internal/getproviders/reattach
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
