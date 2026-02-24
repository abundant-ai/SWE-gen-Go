#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/bootstrap"
cp "/tests/internal/xds/bootstrap/bootstrap_test.go" "internal/xds/bootstrap/bootstrap_test.go"
mkdir -p "internal/xds/xdsclient/pool"
cp "/tests/internal/xds/xdsclient/pool/pool_ext_test.go" "internal/xds/xdsclient/pool/pool_ext_test.go"
mkdir -p "xds/csds"
cp "/tests/xds/csds/csds_e2e_test.go" "xds/csds/csds_e2e_test.go"
mkdir -p "xds"
cp "/tests/xds/server_test.go" "xds/server_test.go"

# Run the specific test packages
test_status=0
go test -v -timeout 7m ./internal/xds/bootstrap || test_status=1
go test -v -timeout 7m ./internal/xds/xdsclient/pool || test_status=1
go test -v -timeout 7m ./xds/csds || test_status=1
go test -v -timeout 7m ./xds -run "TestNewServer_Failure" || test_status=1

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
