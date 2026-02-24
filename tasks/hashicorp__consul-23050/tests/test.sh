#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Apply the fix patch to restore HEAD state (Oracle agent provides this)
if [ -f "/patch/fix.patch" ]; then
    patch -p1 < /patch/fix.patch
    # Re-download dependencies in case go.mod changed
    go mod download
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/consul/state"
cp "/tests/agent/consul/state/peering_test.go" "agent/consul/state/peering_test.go"

# Run the specific test package for this PR
# Test files: agent/consul/state/peering_test.go
go test -v ./agent/consul/state
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
