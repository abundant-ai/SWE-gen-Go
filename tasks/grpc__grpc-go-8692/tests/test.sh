#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/bootstrap"
cp "/tests/internal/xds/bootstrap/bootstrap_test.go" "internal/xds/bootstrap/bootstrap_test.go"
mkdir -p "internal/xds/xdsclient"
cp "/tests/internal/xds/xdsclient/clientimpl_test.go" "internal/xds/xdsclient/clientimpl_test.go"

# Run the specific test packages for this PR
# Test files: internal/xds/bootstrap/bootstrap_test.go, internal/xds/xdsclient/clientimpl_test.go
go test -v -timeout 7m ./internal/xds/bootstrap ./internal/xds/xdsclient
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
