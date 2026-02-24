#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/cloud"
cp "/tests/internal/cloud/backend_test.go" "internal/cloud/backend_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/init_test.go" "internal/command/init_test.go"
mkdir -p "internal/command"
cp "/tests/internal/command/meta_backend_test.go" "internal/command/meta_backend_test.go"

# Run tests for the specific packages
go test -v ./internal/cloud ./internal/command
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
