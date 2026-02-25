#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"

# Run only the FUNCTION tests from this PR
go test -v -run "Loads a new library|Loads and replaces|Deletes a library|Flushes all libraries|Lists registered functions"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
