#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "resolver"
cp "/tests/resolver/map_test.go" "resolver/map_test.go"
mkdir -p "xds/internal/balancer/ringhash"
cp "/tests/xds/internal/balancer/ringhash/ring_test.go" "xds/internal/balancer/ringhash/ring_test.go"
mkdir -p "xds/internal/balancer/ringhash"
cp "/tests/xds/internal/balancer/ringhash/ringhash_test.go" "xds/internal/balancer/ringhash/ringhash_test.go"

# Run the specific test packages for this PR (not subdirectories like e2e)
go test -v -timeout 7m ./resolver ./xds/internal/balancer/ringhash
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
