#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/xds/balancer/clusterresolver"
cp "/tests/internal/xds/balancer/clusterresolver/configbuilder_test.go" "internal/xds/balancer/clusterresolver/configbuilder_test.go"
mkdir -p "internal/xds/balancer/wrrlocality"
cp "/tests/internal/xds/balancer/wrrlocality/balancer_test.go" "internal/xds/balancer/wrrlocality/balancer_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./internal/xds/balancer/clusterresolver ./internal/xds/balancer/wrrlocality
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
