#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/conn_check_test.go" "internal/pool/conn_check_test.go"

# Run the specific test file
go test -v ./internal/pool/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
