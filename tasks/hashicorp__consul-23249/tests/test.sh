#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/connect/ca"
cp "/tests/agent/connect/ca/provider_vault_auth_test.go" "agent/connect/ca/provider_vault_auth_test.go"

# Run only the specific test file from the PR
go test -v ./agent/connect/ca -run "TestVaultCAProvider"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
