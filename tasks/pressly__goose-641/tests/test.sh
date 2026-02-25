#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/provider_collect_test.go" "provider_collect_test.go"
mkdir -p "."
cp "/tests/provider_run_test.go" "provider_run_test.go"

# Run tests for the specific test files from this PR
go test -v -run "TestProviderCollect|TestProviderRun" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
