#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/commands_test.go" "commands_test.go"

# Run only the XINFO CONSUMERS test from this PR
# This test verifies the XInfoConsumers command implementation
go test -v -run "should XINFO CONSUMERS"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
