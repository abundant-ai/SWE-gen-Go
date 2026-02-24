#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "logger"
cp "/tests/logger/slog_test.go" "logger/slog_test.go"

# Run the specific test file
go test -v ./logger -run TestSlogLogger
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
