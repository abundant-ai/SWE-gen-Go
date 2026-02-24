#!/bin/bash

cd /app/src

# Set GOFLAGS to match CI environment
export GOFLAGS="-mod=readonly"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tracing/opencensus"
cp "/tests/tracing/opencensus/jsonrpc_test.go" "tracing/opencensus/jsonrpc_test.go"
mkdir -p "transport/http/jsonrpc"
cp "/tests/transport/http/jsonrpc/server_test.go" "transport/http/jsonrpc/server_test.go"

# Run the specific test files for this PR
go test -v ./tracing/opencensus ./transport/http/jsonrpc
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
