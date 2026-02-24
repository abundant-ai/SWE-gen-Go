#!/bin/bash

cd /app/src

# Set environment variables for Go tests
export CGO_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/text_formatter_test.go" "text_formatter_test.go"

# Run only the specific tests from this PR (TestQuoting and TestTimestampFormat)
go test -v -run "TestQuoting|TestTimestampFormat"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
