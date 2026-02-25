#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/consul"
cp "/tests/agent/consul/acl_test.go" "agent/consul/acl_test.go"
mkdir -p "agent/consul"
cp "/tests/agent/consul/intention_endpoint_test.go" "agent/consul/intention_endpoint_test.go"
mkdir -p "agent/consul"
cp "/tests/agent/consul/rpc_test.go" "agent/consul/rpc_test.go"

# Run the specific tests for the PR
# Only run the tests that were actually modified in the PR, not the entire package
go test -v -timeout=10m -run "^(TestServer_blockingQuery|TestIntentionList_acl)$" ./agent/consul
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
