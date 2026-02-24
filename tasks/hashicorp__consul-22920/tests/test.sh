#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent"
cp "/tests/agent/agent_test.go" "agent/agent_test.go"
mkdir -p "command/services/register"
cp "/tests/command/services/register/register_test.go" "command/services/register/register_test.go"

# Run specific tests from the modified test files
go test -v ./agent -run "^TestAgent_ServiceRegistration$" && \
go test -v ./command/services/register -run "^TestValidateMultiPortWithConnectEnabled$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
