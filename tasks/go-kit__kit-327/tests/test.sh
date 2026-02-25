#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log"
cp "/tests/log/concurrency_test.go" "log/concurrency_test.go"
cp "/tests/log/example_test.go" "log/example_test.go"
cp "/tests/log/json_logger_test.go" "log/json_logger_test.go"
cp "/tests/log/log_test.go" "log/log_test.go"
cp "/tests/log/logfmt_logger_test.go" "log/logfmt_logger_test.go"
cp "/tests/log/nop_logger_test.go" "log/nop_logger_test.go"
cp "/tests/log/sync_test.go" "log/sync_test.go"
cp "/tests/log/value_test.go" "log/value_test.go"

# Run the specific tests for the log package
go test -v ./log -run "Test" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
