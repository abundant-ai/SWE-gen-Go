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
cp "/tests/agent/connect/ca/provider_vault_auth_test.go" "agent/connect/ca/provider_vault_auth_test.go"
mkdir -p "agent/consul/authmethod/awsauth"
cp "/tests/agent/consul/authmethod/awsauth/aws_test.go" "agent/consul/authmethod/awsauth/aws_test.go"

# Run only specific critical tests to avoid memory issues
# Test AWS validator and connect CA provider which are core to the AWS SDK v2 migration
# Note: command/login tests are skipped due to memory constraints when building with AWS SDK v2
go test -v ./agent/consul/authmethod/awsauth -run "TestNewValidator|TestValidateLogin" && \
go test -v ./agent/connect/ca -run "TestAWSProvider_State|TestParseAWSCAConfig|TestVaultCAProvider_AWSAuthClient|TestVaultCAProvider_AWSCredentialsConfig"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
