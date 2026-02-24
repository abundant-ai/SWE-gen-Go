#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/consul/state"
cp "/tests/agent/consul/state/catalog_test.go" "agent/consul/state/catalog_test.go"

# Run the specific test package (agent/consul/state has catalog_test.go)
go test -v ./agent/consul/state
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
