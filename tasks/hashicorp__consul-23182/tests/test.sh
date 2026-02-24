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
mkdir -p "agent"
cp "/tests/agent/agent_test.go" "agent/agent_test.go"
mkdir -p "agent/config"
cp "/tests/agent/config/builder_test.go" "agent/config/builder_test.go"
mkdir -p "agent/config"
cp "/tests/agent/config/runtime_test.go" "agent/config/runtime_test.go"
mkdir -p "agent"
cp "/tests/agent/http_test.go" "agent/http_test.go"
mkdir -p "command/connect/proxy"
cp "/tests/command/connect/proxy/proxy_test.go" "command/connect/proxy/proxy_test.go"
mkdir -p "connect/proxy"
cp "/tests/connect/proxy/proxy_test.go" "connect/proxy/proxy_test.go"

# Run the specific test files for this PR
# Note: Only testing ./agent/config because other packages (./agent, ./command/connect/proxy, ./connect/proxy)
# fail to compile in the buggy state before the fix is applied
go test -v ./agent/config
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
