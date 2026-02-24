#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/configs"
cp "/tests/internal/configs/module_merge_test.go" "internal/configs/module_merge_test.go"

# Run tests for the specific package
go test -v ./internal/configs
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
