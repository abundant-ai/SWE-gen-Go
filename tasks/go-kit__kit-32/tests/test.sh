#!/bin/bash

cd /go/src/github.com/peterbourgon/gokit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log"
cp "/tests/log/log_test.go" "log/log_test.go"
mkdir -p "log"
cp "/tests/log/value_test.go" "log/value_test.go"

# Run the specific tests for log package
go test -v ./log 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
