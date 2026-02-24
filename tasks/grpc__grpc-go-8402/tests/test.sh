#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/balancer/outlierdetection"
cp "/tests/xds/internal/balancer/outlierdetection/balancer_test.go" "xds/internal/balancer/outlierdetection/balancer_test.go"

# Run the specific test package for this PR
# Test files are in: xds/internal/balancer/outlierdetection/
go test -v -timeout 7m ./xds/internal/balancer/outlierdetection/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
