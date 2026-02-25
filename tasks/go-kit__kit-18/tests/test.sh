#!/bin/bash

cd /go/src/github.com/peterbourgon/gokit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/statsd"
cp "/tests/metrics/statsd/statsd_test.go" "metrics/statsd/statsd_test.go"

# Run the specific tests for statsd package
go test -v ./metrics/statsd 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
