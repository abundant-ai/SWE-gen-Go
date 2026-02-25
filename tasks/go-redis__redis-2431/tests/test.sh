#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/pool"
cp "/tests/internal/pool/conncheck_test.go" "internal/pool/conncheck_test.go"
cp "/tests/internal/pool/main_test.go" "internal/pool/main_test.go"
cp "/tests/internal/pool/pool_test.go" "internal/pool/pool_test.go"
cp "/tests/pool_test.go" "pool_test.go"
cp "/tests/sentinel_test.go" "sentinel_test.go"
cp "/tests/tx_test.go" "tx_test.go"

# Run tests for the specific test files from this PR
go test -v ./internal/pool/... -run .
test_status=$?
if [ $test_status -ne 0 ]; then
  if [ $test_status -eq 0 ]; then
    echo 1 > /logs/verifier/reward.txt
  else
    echo 0 > /logs/verifier/reward.txt
  fi
  exit "$test_status"
fi

go test -v -run "TestPoolRemovesBadConn|TestSentinelAclAuth|TestTxPipelineErrValNotSet"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
