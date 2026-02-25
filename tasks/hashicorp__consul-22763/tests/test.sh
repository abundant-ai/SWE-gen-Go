#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent"
cp "/tests/agent/agent_endpoint_test.go" "agent/agent_endpoint_test.go"
mkdir -p "command/connect/envoy"
cp "/tests/command/connect/envoy/envoy_test.go" "command/connect/envoy/envoy_test.go"

# Run the specific test functions modified in this PR
# TestAgent_Monitor from agent package
# TestEnvoyGateway_Validation, TestGenerateConfig, TestEnvoy_GatewayRegistration from command/connect/envoy
go test -v -run "^TestAgent_Monitor$" ./agent
agent_status=$?

go test -v -run "^(TestEnvoyGateway_Validation|TestGenerateConfig|TestEnvoy_GatewayRegistration)$" ./command/connect/envoy
envoy_status=$?

# Both must pass
if [ $agent_status -eq 0 ] && [ $envoy_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
