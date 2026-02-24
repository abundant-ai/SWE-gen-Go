#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/metrics_test.go" "balancer/pickfirst/metrics_test.go"
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/pickfirst_ext_test.go" "balancer/pickfirst/pickfirst_ext_test.go"
mkdir -p "stats/opentelemetry"
cp "/tests/stats/opentelemetry/e2e_test.go" "stats/opentelemetry/e2e_test.go"

# Run the specific test packages for this PR
# Test files: balancer/pickfirst/metrics_test.go, balancer/pickfirst/pickfirst_ext_test.go, stats/opentelemetry/e2e_test.go
go test -v -timeout 7m ./balancer/pickfirst ./stats/opentelemetry
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
