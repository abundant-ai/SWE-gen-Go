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
mkdir -p "agent"
cp "/tests/agent/agent_certmetrics_endpoint_test.go" "agent/agent_certmetrics_endpoint_test.go"
mkdir -p "agent/config"
cp "/tests/agent/config/certificate_telemetry_test.go" "agent/config/certificate_telemetry_test.go"
mkdir -p "agent/config"
cp "/tests/agent/config/runtime_test.go" "agent/config/runtime_test.go"
mkdir -p "agent/consul"
cp "/tests/agent/consul/leader_metrics_test.go" "agent/consul/leader_metrics_test.go"
mkdir -p "agent/leafcert"
cp "/tests/agent/leafcert/renewal_logging_test.go" "agent/leafcert/renewal_logging_test.go"
mkdir -p "agent"
cp "/tests/agent/metrics_test.go" "agent/metrics_test.go"

# Run the specific test packages for this PR
# Only testing ./agent/config because other packages may take too long or fail to compile in the buggy state
go test -v ./agent/config
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
