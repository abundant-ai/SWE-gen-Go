#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/bootstrap"
cp "/tests/internal/xds/bootstrap/bootstrap_test.go" "internal/xds/bootstrap/bootstrap_test.go"
mkdir -p "xds/internal/clients/xdsclient"
cp "/tests/xds/internal/clients/xdsclient/helpers_test.go" "xds/internal/clients/xdsclient/helpers_test.go"
mkdir -p "xds/internal/clients/xdsclient/test"
cp "/tests/xds/internal/clients/xdsclient/test/helpers_test.go" "xds/internal/clients/xdsclient/test/helpers_test.go"
mkdir -p "xds/internal/xdsclient/pool"
cp "/tests/xds/internal/xdsclient/pool/pool_test.go" "xds/internal/xdsclient/pool/pool_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/xds/bootstrap ./xds/internal/clients/xdsclient ./xds/internal/clients/xdsclient/test ./xds/internal/xdsclient/pool
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
