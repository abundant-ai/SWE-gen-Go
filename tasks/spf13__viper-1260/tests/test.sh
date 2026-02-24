#!/bin/bash

cd /app/src

# Set CGO_ENABLED for race detector (as used in CI)
export CGO_ENABLED=1

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/util_test.go" "util_test.go"

# Run util_test.go with race detector
go test -v -race -run "TestCopyAndInsensitiviseMap|TestAbsPathify" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
