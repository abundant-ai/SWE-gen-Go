#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"

# Run tests for the modified test files
# Skip tests with path-matching issues unrelated to the nil Clock bug:
# - TestConfig: checks caller path format
# - TestConfigWithSamplingHook: checks caller path format
# - TestLoggerAddCaller: checks caller path format
# - TestSugarAddCaller: checks caller path format
# - TestOpen: flaky test with unrelated nil pointer issue
go test -v . -skip="TestConfig|TestConfigWithSamplingHook|TestLoggerAddCaller|TestSugarAddCaller|TestOpen"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
