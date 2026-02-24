#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/xdsclient/xdsresource"
cp "/tests/xds/internal/xdsclient/xdsresource/filter_chain_test.go" "xds/internal/xdsclient/xdsresource/filter_chain_test.go"
mkdir -p "xds/internal/xdsclient/xdsresource"
cp "/tests/xds/internal/xdsclient/xdsresource/unmarshal_lds_test.go" "xds/internal/xdsclient/xdsresource/unmarshal_lds_test.go"

# Run the specific test package for this PR
# Test files are in: xds/internal/xdsclient/xdsresource/
go test -v -timeout 7m ./xds/internal/xdsclient/xdsresource/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
