#!/bin/bash

cd /app/src

# Set environment variables for tests
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "command/connect/envoy"
cp "/tests/command/connect/envoy/envoy_test.go" "command/connect/envoy/envoy_test.go"
mkdir -p "test/integration/connect/envoy"
cp "/tests/integration/connect/envoy/helpers.bash" "test/integration/connect/envoy/helpers.bash"
mkdir -p "test/integration/connect/envoy"
cp "/tests/integration/connect/envoy/run-tests.sh" "test/integration/connect/envoy/run-tests.sh"

# Run the specific test package (command/connect/envoy has envoy_test.go)
go test -v ./command/connect/envoy
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
