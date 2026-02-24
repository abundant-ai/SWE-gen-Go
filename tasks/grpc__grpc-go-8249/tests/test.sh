#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/config_test.go" "balancer/ringhash/config_test.go"
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/picker_test.go" "balancer/ringhash/picker_test.go"
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/ring_test.go" "balancer/ringhash/ring_test.go"
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/ringhash_e2e_test.go" "balancer/ringhash/ringhash_e2e_test.go"
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/ringhash_test.go" "balancer/ringhash/ringhash_test.go"
mkdir -p "xds/internal/balancer/cdsbalancer"
cp "/tests/xds/internal/balancer/cdsbalancer/cdsbalancer_test.go" "xds/internal/balancer/cdsbalancer/cdsbalancer_test.go"
mkdir -p "xds/internal/balancer/clusterresolver"
cp "/tests/xds/internal/balancer/clusterresolver/config_test.go" "xds/internal/balancer/clusterresolver/config_test.go"
mkdir -p "xds/internal/balancer/clusterresolver"
cp "/tests/xds/internal/balancer/clusterresolver/configbuilder_test.go" "xds/internal/balancer/clusterresolver/configbuilder_test.go"
mkdir -p "xds/internal/resolver"
cp "/tests/xds/internal/resolver/xds_resolver_test.go" "xds/internal/resolver/xds_resolver_test.go"
mkdir -p "xds/internal/xdsclient/xdsresource/tests"
cp "/tests/xds/internal/xdsclient/xdsresource/tests/unmarshal_cds_test.go" "xds/internal/xdsclient/xdsresource/tests/unmarshal_cds_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./balancer/ringhash/... ./xds/internal/balancer/cdsbalancer/... ./xds/internal/balancer/clusterresolver/... ./xds/internal/resolver/... ./xds/internal/xdsclient/xdsresource/tests/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
