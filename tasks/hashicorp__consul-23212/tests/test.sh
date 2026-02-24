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
mkdir -p "agent/xds"
cp "/tests/agent/xds/listeners_apigateway_test.go" "agent/xds/listeners_apigateway_test.go"

# Run the specific test file for this PR
go test -v ./agent/xds -run "TestMakeInlineOverrideFilterChains_FileSystemCertificates"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
