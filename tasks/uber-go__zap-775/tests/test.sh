#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/increase_level_test.go" "increase_level_test.go"
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/increase_level_test.go" "zapcore/increase_level_test.go"

# Run tests from modified packages
# Tests for PR #775 (increase_level_test.go, logger_test.go, zapcore/increase_level_test.go):
# - Root package: increase_level_test.go and logger_test.go tests
# - zapcore package: increase_level_test.go tests

# Run root package tests (increase_level_test.go and logger_test.go)
go test -v . -run "TestIncreaseLevel|TestLoggerLevel"
root_status=$?

# Run zapcore tests (increase_level_test.go)
go test -v ./zapcore -run "TestIncreaseLevel"
zapcore_status=$?

# Both test suites must pass
if [ $root_status -eq 0 ] && [ $zapcore_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
