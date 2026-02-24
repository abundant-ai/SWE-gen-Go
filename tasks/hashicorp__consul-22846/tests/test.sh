#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent"
cp "/tests/agent/agent_endpoint_test.go" "agent/agent_endpoint_test.go"
mkdir -p "agent/config"
cp "/tests/agent/config/runtime_test.go" "agent/config/runtime_test.go"
mkdir -p "agent/structs"
cp "/tests/agent/structs/structs_test.go" "agent/structs/structs_test.go"
mkdir -p "api"
cp "/tests/api/agent_test.go" "api/agent_test.go"

# Run specific tests from the modified test files
# Run each package separately to ensure all tests run even if some fail
test_status=0
go test -v ./agent/config || test_status=$?
go test -v ./agent/structs || test_status=$?
# Run specific tests from agent package (not entire package, too slow)
go test -v ./agent -run "TestAgent_Services|TestAgent_Self" || test_status=$?
# api is a separate module, so cd into it to run its tests
(cd api && go test -v ./ -run "TestServicePortsValidation") || test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
