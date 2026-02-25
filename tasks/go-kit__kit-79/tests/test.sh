#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log"
cp "/tests/log/nop_logger_test.go" "log/nop_logger_test.go"
mkdir -p "tracing/zipkin"
cp "/tests/tracing/zipkin/collector_internal_test.go" "tracing/zipkin/collector_internal_test.go"
mkdir -p "tracing/zipkin"
cp "/tests/tracing/zipkin/collector_test.go" "tracing/zipkin/collector_test.go"
mkdir -p "tracing/zipkin"
cp "/tests/tracing/zipkin/zipkin_test.go" "tracing/zipkin/zipkin_test.go"

# Run the specific tests for the log and tracing/zipkin packages
go test -v ./log ./tracing/zipkin 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
