#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapcore"
cp "/tests/zapcore/console_encoder_test.go" "zapcore/console_encoder_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/json_encoder_test.go" "zapcore/json_encoder_test.go"

# Run tests in the zapcore package where the test files are located
go test -v ./zapcore
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
