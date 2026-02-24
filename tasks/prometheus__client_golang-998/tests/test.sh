#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/internal"
cp "/tests/prometheus/internal/difflib_test.go" "prometheus/internal/difflib_test.go"
mkdir -p "prometheus/testutil"
cp "/tests/prometheus/testutil/testutil_test.go" "prometheus/testutil/testutil_test.go"

# Run the specific tests from the PR test files
go test -v ./prometheus/internal ./prometheus/testutil 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
