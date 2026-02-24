#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Apply the fix patch to restore HEAD state (Oracle agent provides this)
if [ -f "/patch/fix.patch" ]; then
    patch -p1 < /patch/fix.patch
    # Re-download dependencies in case go.mod changed
    go mod download
fi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/connect/ca"
cp "/tests/agent/connect/ca/provider_aws_test.go" "agent/connect/ca/provider_aws_test.go"
mkdir -p "agent/connect/ca"
cp "/tests/agent/connect/ca/provider_vault_auth_test.go" "agent/connect/ca/provider_vault_auth_test.go"
mkdir -p "agent/consul/authmethod/awsauth"
cp "/tests/agent/consul/authmethod/awsauth/aws_test.go" "agent/consul/authmethod/awsauth/aws_test.go"
mkdir -p "command/login"
cp "/tests/command/login/login_test.go" "command/login/login_test.go"

# Run the specific test packages for this PR
# Test files: agent/connect/ca/provider_aws_test.go, agent/connect/ca/provider_vault_auth_test.go
#             agent/consul/authmethod/awsauth/aws_test.go, command/login/login_test.go
# Only testing ./agent/connect/ca and ./agent/consul/authmethod/awsauth because ./command/login fails to compile in the buggy state
go test -v ./agent/connect/ca ./agent/consul/authmethod/awsauth
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
