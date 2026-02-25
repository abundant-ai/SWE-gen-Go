#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapcore"
cp "/tests/zapcore/encoder_test.go" "zapcore/encoder_test.go"

# Run tests for the modified test files
# Skip TestSamplerConcurrent which is flaky at this commit (fixed in PR #1012)
go test -v ./zapcore/... -skip=TestSamplerConcurrent
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
