#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/entry_test.go" "zapcore/entry_test.go"

# Run specific tests related to PR #861 (OnFatal functionality)
# The PR removes the OnFatal option and related tests
# We run the parent TestCheckedEntryWrite test which includes subtests
go test -v ./zapcore -run "^TestCheckedEntryWrite$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
