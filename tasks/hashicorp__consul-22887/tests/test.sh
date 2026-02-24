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
go test -v ./agent -run "TestAgent_ReloadMaxHeaderBytes|TestAgent_ReloadMaxConnsPerClient" && \
go test -v ./agent/config -run "TestLoad_FullConfig" && \
go test -v ./agent/structs && \
cd api && go test -v -run "TestAPI_AgentMaxHeaderBytes|TestAPI_AgentMaxConnsPerClient"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
