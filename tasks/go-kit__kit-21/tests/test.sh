#!/bin/bash

cd /go/src/github.com/peterbourgon/gokit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log"
cp "/tests/log/benchmark_test.go" "log/benchmark_test.go"
mkdir -p "log"
cp "/tests/log/json_logger_test.go" "log/json_logger_test.go"
mkdir -p "log"
cp "/tests/log/levels_test.go" "log/levels_test.go"
mkdir -p "log"
cp "/tests/log/log_test.go" "log/log_test.go"
mkdir -p "log"
cp "/tests/log/prefix_logger_test.go" "log/prefix_logger_test.go"
mkdir -p "log"
cp "/tests/log/stdlib_writer_test.go" "log/stdlib_writer_test.go"

# Run the specific tests for log package
go test -v ./log 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
