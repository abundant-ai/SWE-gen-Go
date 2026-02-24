#!/bin/bash

cd /app/src

# Set environment variables for Go tests
export CGO_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/formatter_bench_test.go" "formatter_bench_test.go"
cp "/tests/logrus_test.go" "logrus_test.go"

# Run only the specific test that verifies the fix for this PR
# Disable vet to allow compilation (code has fmt.Fprintf with missing format directives)
# TestDefaultFieldsAreNotPrefixed is the regression test added in this PR
go test -vet=off -v -run TestDefaultFieldsAreNotPrefixed .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
