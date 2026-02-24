#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/command_test.go" "command_test.go"
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"

# Run tests from the specific test files modified in this PR
# command_test.go and completions_test.go - run tests in the root package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
