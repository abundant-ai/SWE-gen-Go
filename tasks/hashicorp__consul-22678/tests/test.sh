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

# Run the specific tests in agent/consul package that verify the changes
go test -v -timeout=2m ./agent/consul -run='TestACL|TestIntention|TestRPC'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
