#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"

# Run tests from completions_test.go
# Use a pattern that matches the modified tests in this file
go test -v -run "^Test(DefaultCompletionCmd|CompleteCompletion)$" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
