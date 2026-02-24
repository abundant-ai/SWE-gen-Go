#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/bootstrap"
cp "/tests/internal/xds/bootstrap/bootstrap_test.go" "internal/xds/bootstrap/bootstrap_test.go"
mkdir -p "xds/internal/xdsclient/pool"
cp "/tests/xds/internal/xdsclient/pool/pool_test.go" "xds/internal/xdsclient/pool/pool_test.go"

# Run the specific test packages for this PR
# Test files are in: internal/xds/bootstrap/ and xds/internal/xdsclient/pool/
go test -v -timeout 7m ./internal/xds/bootstrap/... ./xds/internal/xdsclient/pool/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
