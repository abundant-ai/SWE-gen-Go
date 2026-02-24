#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/config"
cp "/tests/agent/config/runtime_test.go" "agent/config/runtime_test.go"
mkdir -p "agent"
cp "/tests/agent/kvs_endpoint_test.go" "agent/kvs_endpoint_test.go"

# Run specific tests from the modified test files
go test -v ./agent/config ./agent -run "TestRuntimeConfig|TestKVSEndpoint"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
