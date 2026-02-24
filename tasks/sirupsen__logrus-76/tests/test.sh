#!/bin/bash

cd /app/src

# Set environment variables for Go tests
export CGO_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/entry_test.go" "entry_test.go"

# Run only the specific tests from entry_test.go for this PR
go test -v -run "^(TestEntryPanicln|TestEntryPanicf)$" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
