#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/pickfirst_ext_test.go" "balancer/pickfirst/pickfirst_ext_test.go"
mkdir -p "balancer/pickfirst/pickfirstleaf"
cp "/tests/balancer/pickfirst/pickfirstleaf/pickfirstleaf_ext_test.go" "balancer/pickfirst/pickfirstleaf/pickfirstleaf_ext_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./balancer/pickfirst ./balancer/pickfirst/pickfirstleaf
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
