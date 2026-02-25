#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log/experimental_level"
cp "/tests/log/experimental_level/benchmark_test.go" "log/experimental_level/benchmark_test.go"
mkdir -p "log/experimental_level"
cp "/tests/log/experimental_level/level_test.go" "log/experimental_level/level_test.go"
mkdir -p "log"
cp "/tests/log/nop_logger_test.go" "log/nop_logger_test.go"

# Run the specific tests for the log package
go test -v ./log/experimental_level ./log -run "Test|Benchmark" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
