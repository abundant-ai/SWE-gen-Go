#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tracing/zipkin"
cp "/tests/tracing/zipkin/http_test.go" "tracing/zipkin/http_test.go"

# Temporarily rename grpc files to avoid compilation issues with missing dependencies
mv tracing/zipkin/grpc.go tracing/zipkin/grpc.go.bak 2>/dev/null || true
mv tracing/zipkin/grpc_test.go tracing/zipkin/grpc_test.go.bak 2>/dev/null || true

# Run the tests for this PR, excluding the network-dependent test
# TestHTTPClientTracePropagatesParentSpan requires external network access and is not part of this PR's changes
go test -v -run "TestHTTPClientTraceAddsExpectedTags|TestHTTPServerTrace|TestHTTPServerTraceIsRequestBasedSampled|TestTraceEndpoint" ./tracing/zipkin
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
