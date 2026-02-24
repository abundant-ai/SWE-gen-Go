#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/xdsclient/xdsresource"
cp "/tests/internal/xds/xdsclient/xdsresource/unmarshal_eds_test.go" "internal/xds/xdsclient/xdsresource/unmarshal_eds_test.go"

# Run the specific test package (Go tests are run by package, not by file)
# Test file is in: internal/xds/xdsclient/xdsresource
go test -v -timeout 7m ./internal/xds/xdsclient/xdsresource
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
