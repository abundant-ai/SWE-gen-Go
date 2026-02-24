#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/clients/xdsclient"
cp "/tests/internal/xds/clients/xdsclient/channel_test.go" "internal/xds/clients/xdsclient/channel_test.go"
mkdir -p "internal/xds/clients/xdsclient/test"
cp "/tests/internal/xds/clients/xdsclient/test/misc_watchers_test.go" "internal/xds/clients/xdsclient/test/misc_watchers_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/xds/clients/xdsclient ./internal/xds/clients/xdsclient/test
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
