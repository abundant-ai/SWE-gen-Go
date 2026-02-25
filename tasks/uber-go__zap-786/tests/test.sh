#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "buffer"
cp "/tests/buffer/buffer_test.go" "buffer/buffer_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/json_encoder_impl_test.go" "zapcore/json_encoder_impl_test.go"

# Run tests from modified packages
# Tests for PR #786 (buffer/buffer_test.go and zapcore/json_encoder_impl_test.go):
# - buffer package: buffer_test.go tests
# - zapcore package: json_encoder_impl_test.go tests

# Run buffer tests
go test -v ./buffer
buffer_status=$?

# Run zapcore tests (specifically json encoder tests)
go test -v ./zapcore -run "TestJSON"
zapcore_status=$?

# Both test suites must pass
if [ $buffer_status -eq 0 ] && [ $zapcore_status -eq 0 ]; then
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
