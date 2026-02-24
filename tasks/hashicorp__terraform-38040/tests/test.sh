#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/cloud"
cp "/tests/internal/cloud/backend_query_test.go" "internal/cloud/backend_query_test.go"

# Run tests for the specific package
go test -v ./internal/cloud
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
