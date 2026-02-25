#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/exit"
cp "/tests/internal/exit/exit_test.go" "internal/exit/exit_test.go"
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/entry_test.go" "zapcore/entry_test.go"

# Run tests from the three modified test files
go test -v ./internal/exit && go test -v -run "^TestLogger" . && go test -v ./zapcore
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
