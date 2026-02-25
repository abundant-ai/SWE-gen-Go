#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/xds"
cp "/tests/agent/xds/listeners_test.go" "agent/xds/listeners_test.go"
mkdir -p "agent/xds"
cp "/tests/agent/xds/resources_test.go" "agent/xds/resources_test.go"

# Run the specific tests in agent/xds package that verify the changes
go test -v -timeout=2m ./agent/xds -run='Test.*'
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
