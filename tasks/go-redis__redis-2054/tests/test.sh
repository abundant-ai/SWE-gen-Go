#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/conn_check_test.go" "internal/pool/conn_check_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/export_test.go" "internal/pool/export_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/main_test.go" "internal/pool/main_test.go"
mkdir -p "internal/pool"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"
mkdir -p "."
cp "/tests/pool_test.go" "pool_test.go"
mkdir -p "."
cp "/tests/sentinel_test.go" "sentinel_test.go"
mkdir -p "."
cp "/tests/tx_test.go" "tx_test.go"

# Run the specific test packages for this PR
# Testing internal/pool package and specific root level tests
go test -v ./internal/pool && go test -v . -run="^(TestPoolReuse|TestSentinel|TestTx)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
