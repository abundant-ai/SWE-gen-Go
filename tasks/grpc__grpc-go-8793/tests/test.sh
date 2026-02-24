#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/balancer/cdsbalancer"
cp "/tests/internal/xds/balancer/cdsbalancer/cdsbalancer_test.go" "internal/xds/balancer/cdsbalancer/cdsbalancer_test.go"
mkdir -p "internal/xds/clusterspecifier/rls"
cp "/tests/internal/xds/clusterspecifier/rls/rls_test.go" "internal/xds/clusterspecifier/rls/rls_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/xds/balancer/cdsbalancer ./internal/xds/clusterspecifier/rls
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
