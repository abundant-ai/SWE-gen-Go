#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/xds"
cp "/tests/xds/xds_telemetry_labels_test.go" "test/xds/xds_telemetry_labels_test.go"

# Run the specific test package for this PR
go test -v -timeout 7m ./test/xds
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
