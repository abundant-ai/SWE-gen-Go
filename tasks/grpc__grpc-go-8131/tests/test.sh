#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "test/xds"
cp "/tests/xds/xds_client_ignore_resource_deletion_test.go" "test/xds/xds_client_ignore_resource_deletion_test.go"
mkdir -p "xds/internal/balancer/cdsbalancer"
cp "/tests/xds/internal/balancer/cdsbalancer/cdsbalancer_test.go" "xds/internal/balancer/cdsbalancer/cdsbalancer_test.go"
mkdir -p "xds/internal/resolver"
cp "/tests/xds/internal/resolver/cluster_specifier_plugin_test.go" "xds/internal/resolver/cluster_specifier_plugin_test.go"
mkdir -p "xds/internal/resolver"
cp "/tests/xds/internal/resolver/helpers_test.go" "xds/internal/resolver/helpers_test.go"
mkdir -p "xds/internal/resolver"
cp "/tests/xds/internal/resolver/watch_service_test.go" "xds/internal/resolver/watch_service_test.go"
mkdir -p "xds/internal/resolver"
cp "/tests/xds/internal/resolver/xds_resolver_test.go" "xds/internal/resolver/xds_resolver_test.go"

# Run tests on the specific packages
# Tests in test/xds, xds/internal/balancer/cdsbalancer, and xds/internal/resolver
go test -v -timeout 7m ./test/xds ./xds/internal/balancer/cdsbalancer ./xds/internal/resolver
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
