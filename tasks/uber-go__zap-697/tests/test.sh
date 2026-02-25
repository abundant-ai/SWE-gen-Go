#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapcore"
cp "/tests/zapcore/console_encoder_test.go" "zapcore/console_encoder_test.go"

# Run tests from modified packages
# Tests for PR #697 (zapcore/console_encoder_test.go)
go test -v ./zapcore -run "TestConsole"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
