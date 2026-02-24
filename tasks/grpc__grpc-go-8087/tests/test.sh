#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/balancer/weight"
cp "/tests/internal/balancer/weight/weight_test.go" "internal/balancer/weight/weight_test.go"
mkdir -p "xds/internal/balancer/clusterresolver"
cp "/tests/xds/internal/balancer/clusterresolver/configbuilder_test.go" "xds/internal/balancer/clusterresolver/configbuilder_test.go"
mkdir -p "xds/internal/balancer/ringhash"
cp "/tests/xds/internal/balancer/ringhash/ring_test.go" "xds/internal/balancer/ringhash/ring_test.go"
mkdir -p "xds/internal/balancer/ringhash"
cp "/tests/xds/internal/balancer/ringhash/ringhash_test.go" "xds/internal/balancer/ringhash/ringhash_test.go"

# Run tests on the specific packages
go test -v -timeout 7m ./internal/balancer/weight ./xds/internal/balancer/clusterresolver ./xds/internal/balancer/ringhash
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
