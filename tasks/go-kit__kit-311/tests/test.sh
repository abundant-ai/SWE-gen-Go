#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tracing/opentracing"
cp "/tests/tracing/opentracing/endpoint_test.go" "tracing/opentracing/endpoint_test.go"
cp "/tests/tracing/opentracing/grpc_test.go" "tracing/opentracing/grpc_test.go"
cp "/tests/tracing/opentracing/http_test.go" "tracing/opentracing/http_test.go"

# Run the specific tests for the opentracing package
go test -v ./tracing/opentracing -run "Test" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
