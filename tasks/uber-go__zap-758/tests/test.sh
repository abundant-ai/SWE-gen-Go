#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/field_test.go" "field_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/json_encoder_test.go" "zapcore/json_encoder_test.go"

# Run tests from modified packages
# Tests for PR #758 (field_test.go, zapcore/json_encoder_test.go):
# - Root package: field_test.go tests
# - zapcore package: json_encoder_test.go tests

# Run root package tests (field_test.go)
go test -v . -run "TestField"
root_status=$?

# Run zapcore tests (json_encoder_test.go)
go test -v ./zapcore -run "TestJSON"
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
