#!/bin/bash

# Use GOPATH mode and correct directory
export GO111MODULE=off
export GOPATH=/go
cd /go/src/go.uber.org/zap

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/array_test.go" "array_test.go"
mkdir -p "."
cp "/tests/error_test.go" "error_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/field_test.go" "zapcore/field_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/memory_encoder_test.go" "zapcore/memory_encoder_test.go"

# Run tests from modified files only
# Tests for PR #614 - run specific tests from the modified test files only
go test -v -run "TestArrayWrappers|TestErrorConstructors|TestErrorArrayConstructor|TestErrorsArraysHandleRichErrors" . && \
go test -v -run "TestUnknownFieldType|TestFieldAddingError|TestFields|TestEquals|TestMapObjectEncoderAdd|TestSliceArrayEncoderAppend|TestMapObjectEncoderReflectionFailures" ./zapcore
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
