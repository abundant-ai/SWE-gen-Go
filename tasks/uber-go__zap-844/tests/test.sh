#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/logger_test.go" "logger_test.go"
cp "/tests/zapcore/console_encoder_test.go" "zapcore/console_encoder_test.go"
cp "/tests/zapcore/encoder_test.go" "zapcore/encoder_test.go"
cp "/tests/zapcore/json_encoder_test.go" "zapcore/json_encoder_test.go"

# Run specific tests related to PR #844 (function name in caller info)
# The main new test is TestLoggerAddCallerFunction
go test -v . -run "^TestLoggerAddCallerFunction$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
