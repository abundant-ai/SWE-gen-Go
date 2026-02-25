#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/field_test.go" "field_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/field_test.go" "zapcore/field_test.go"

# Run tests from modified packages
# Tests for PR #804 (field_test.go changes):
# - Root package: field_test.go tests
# - zapcore package: field_test.go tests

# Run field tests from root package
go test -v . -run "TestField"
main_status=$?

# Run field tests from zapcore package
go test -v ./zapcore -run "TestField"
zapcore_status=$?

# Exit with failure if any test failed
if [ $main_status -ne 0 ] || [ $zapcore_status -ne 0 ]; then
  test_status=1
else
  test_status=0
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
