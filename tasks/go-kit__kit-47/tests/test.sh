#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Remove prefix_logger_test.go (bug.patch renamed logfmt_logger_test.go to this)
rm -f log/prefix_logger_test.go

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log"
cp "/tests/log/levels_test.go" "log/levels_test.go"
cp "/tests/log/log_test.go" "log/log_test.go"
cp "/tests/log/logfmt_logger_test.go" "log/logfmt_logger_test.go"
cp "/tests/log/stdlib_test.go" "log/stdlib_test.go"

# Run the specific tests for the log package
go test -v ./log 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
