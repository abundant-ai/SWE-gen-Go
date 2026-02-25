#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/consul"
cp "/tests/agent/consul/catalog_endpoint_test.go" "agent/consul/catalog_endpoint_test.go"

# Run the specific test that was added in the fix
go test -v -timeout=10m -run TestCatalog_Register_RejectsMissingServiceName ./agent/consul
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
