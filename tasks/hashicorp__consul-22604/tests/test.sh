#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true
export GOFLAGS="-buildvcs=false"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "agent/xds/config"
cp "/tests/agent/xds/config/config_test.go" "agent/xds/config/config_test.go"
mkdir -p "agent/xds"
cp "/tests/agent/xds/listeners_test.go" "agent/xds/listeners_test.go"
mkdir -p "agent/xds"
cp "/tests/agent/xds/resources_test.go" "agent/xds/resources_test.go"
mkdir -p "test/integration/connect/envoy/case-max-request-headers"
cp "/tests/integration/connect/envoy/case-max-request-headers/capture.sh" "test/integration/connect/envoy/case-max-request-headers/capture.sh"
mkdir -p "test/integration/connect/envoy/case-max-request-headers"
cp "/tests/integration/connect/envoy/case-max-request-headers/service_s1.hcl" "test/integration/connect/envoy/case-max-request-headers/service_s1.hcl"
mkdir -p "test/integration/connect/envoy/case-max-request-headers"
cp "/tests/integration/connect/envoy/case-max-request-headers/service_s2.hcl" "test/integration/connect/envoy/case-max-request-headers/service_s2.hcl"
mkdir -p "test/integration/connect/envoy/case-max-request-headers"
cp "/tests/integration/connect/envoy/case-max-request-headers/setup.sh" "test/integration/connect/envoy/case-max-request-headers/setup.sh"
mkdir -p "test/integration/connect/envoy/case-max-request-headers"
cp "/tests/integration/connect/envoy/case-max-request-headers/verify.bats" "test/integration/connect/envoy/case-max-request-headers/verify.bats"
mkdir -p "test/integration/connect/envoy"
cp "/tests/integration/connect/envoy/helpers.bash" "test/integration/connect/envoy/helpers.bash"

# Run the specific tests for the PR (agent/xds/config and agent/xds packages)
go test -v -timeout=2m ./agent/xds/config ./agent/xds
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
