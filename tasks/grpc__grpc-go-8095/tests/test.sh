#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/balancergroup"
cp "/tests/internal/balancergroup/balancergroup_test.go" "internal/balancergroup/balancergroup_test.go"

# Run tests on the specific package
go test -v -timeout 7m ./internal/balancergroup
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
