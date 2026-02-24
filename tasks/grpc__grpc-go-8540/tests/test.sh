#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/clients/xdsclient"
cp "/tests/xds/internal/clients/xdsclient/xdsclient_test.go" "xds/internal/clients/xdsclient/xdsclient_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/loadreport_test.go" "xds/internal/xdsclient/tests/loadreport_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./xds/internal/clients/xdsclient ./xds/internal/xdsclient/tests
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
