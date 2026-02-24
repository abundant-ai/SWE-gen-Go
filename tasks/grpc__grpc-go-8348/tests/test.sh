#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/clients/lrsclient"
cp "/tests/xds/internal/clients/lrsclient/load_store_test.go" "xds/internal/clients/lrsclient/load_store_test.go"
mkdir -p "xds/internal/clients/lrsclient"
cp "/tests/xds/internal/clients/lrsclient/loadreport_test.go" "xds/internal/clients/lrsclient/loadreport_test.go"
mkdir -p "xds/internal/xdsclient/load"
cp "/tests/xds/internal/xdsclient/load/store_test.go" "xds/internal/xdsclient/load/store_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./xds/internal/clients/lrsclient/... ./xds/internal/xdsclient/load/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
