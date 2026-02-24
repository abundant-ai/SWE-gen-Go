#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/testutil"
cp "/tests/prometheus/testutil/testutil_test.go" "prometheus/testutil/testutil_test.go"

# Run tests for the package containing the test files
go test -v ./prometheus/testutil
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
