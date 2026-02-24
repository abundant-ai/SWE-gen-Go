#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/pickfirst_ext_test.go" "balancer/pickfirst/pickfirst_ext_test.go"
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/ringhash_e2e_test.go" "balancer/ringhash/ringhash_e2e_test.go"
mkdir -p "internal/xds/balancer/clusterresolver"
cp "/tests/internal/xds/balancer/clusterresolver/configbuilder_test.go" "internal/xds/balancer/clusterresolver/configbuilder_test.go"

# Run the specific test packages (Go tests are run by package, not by file)
# Test files are in: balancer/pickfirst, balancer/ringhash, internal/xds/balancer/clusterresolver
go test -v -timeout 7m ./balancer/pickfirst ./balancer/ringhash ./internal/xds/balancer/clusterresolver
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
