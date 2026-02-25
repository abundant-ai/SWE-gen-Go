#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "auth/jwt"
cp "/tests/auth/jwt/transport_test.go" "auth/jwt/transport_test.go"
mkdir -p "tracing/opentracing"
cp "/tests/tracing/opentracing/grpc_test.go" "tracing/opentracing/grpc_test.go"
mkdir -p "tracing/opentracing"
cp "/tests/tracing/opentracing/http_test.go" "tracing/opentracing/http_test.go"

# Run the tests for this PR
go test -v ./auth/jwt ./tracing/opentracing
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
