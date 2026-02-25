#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/netutil"
cp "/tests/agent/netutil/network_test.go" "agent/netutil/network_test.go"
mkdir -p "test/integration/consul-container"
cp "/tests/integration/consul-container/go.mod" "test/integration/consul-container/go.mod"
mkdir -p "test/integration/consul-container"
cp "/tests/integration/consul-container/go.sum" "test/integration/consul-container/go.sum"

# Run the specific tests that were added/modified in this PR
go test -v ./agent/netutil
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
