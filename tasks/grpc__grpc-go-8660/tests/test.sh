#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true
# At BASE, the code allows ALPN to be disabled via this env var. Setting it to false
# should cause tests to fail because tests expect strict ALPN enforcement.
# At FIXED, this env var is removed/ignored, so ALPN is always enforced and tests pass.
export GRPC_ENFORCE_ALPN_ENABLED=false

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "credentials"
cp "/tests/credentials/tls_ext_test.go" "credentials/tls_ext_test.go"

# Run the specific test package for this PR
# Only test ./credentials because the fix doesn't affect experimental/credentials behavior
go test -v -timeout 7m ./credentials
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
