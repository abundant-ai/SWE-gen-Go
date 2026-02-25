#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/example_test.go" "example_test.go"
mkdir -p "."
cp "/tests/field_test.go" "field_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/field_test.go" "zapcore/field_test.go"

# Run tests for the modified test files
# Testing example_test.go and field_test.go in root package
go test -v . -run "TestExample|TestField"
test_status_root=$?

# Testing zapcore/field_test.go
go test -v ./zapcore -run "TestField"
test_status_zapcore=$?

# Both test runs must pass
if [ $test_status_root -eq 0 ] && [ $test_status_zapcore -eq 0 ]; then
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
