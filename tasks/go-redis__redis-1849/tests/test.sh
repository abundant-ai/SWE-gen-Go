#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/main_test.go" "internal/pool/main_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"

# Remove conncheck_test.go from BASE (it's deleted at HEAD)
rm -f internal/pool/conncheck_test.go

# Test internal/pool package
go test -v ./internal/pool
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
