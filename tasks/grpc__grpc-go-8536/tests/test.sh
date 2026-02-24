#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/bootstrap"
cp "/tests/internal/xds/bootstrap/bootstrap_test.go" "internal/xds/bootstrap/bootstrap_test.go"
mkdir -p "internal/xds/bootstrap/jwtcreds"
cp "/tests/internal/xds/bootstrap/jwtcreds/call_creds_test.go" "internal/xds/bootstrap/jwtcreds/call_creds_test.go"
mkdir -p "internal/xds/xdsclient"
cp "/tests/internal/xds/xdsclient/clientimpl_test.go" "internal/xds/xdsclient/clientimpl_test.go"
mkdir -p "internal/xds/xdsclient/tests"
cp "/tests/internal/xds/xdsclient/tests/client_custom_dialopts_test.go" "internal/xds/xdsclient/tests/client_custom_dialopts_test.go"
mkdir -p "xds/bootstrap"
cp "/tests/xds/bootstrap/bootstrap_test.go" "xds/bootstrap/bootstrap_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/xds/bootstrap ./internal/xds/bootstrap/jwtcreds ./internal/xds/xdsclient ./internal/xds/xdsclient/tests ./xds/bootstrap
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
