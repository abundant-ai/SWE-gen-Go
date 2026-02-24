#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds"
cp "/tests/xds/server_ext_test.go" "xds/server_ext_test.go"
cp "/tests/xds/server_resource_ext_test.go" "xds/server_resource_ext_test.go"
cp "/tests/xds/server_security_ext_test.go" "xds/server_security_ext_test.go"
cp "/tests/xds/server_serving_mode_ext_test.go" "xds/server_serving_mode_ext_test.go"

# Run tests on the xds package
# Note: test/xds/xds_server_rbac_test.go is excluded due to package build issues in BASE state
go test -v -timeout 7m ./xds
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
