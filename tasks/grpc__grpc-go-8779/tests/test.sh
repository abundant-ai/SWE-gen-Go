#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/ringhash"
cp "/tests/balancer/ringhash/ringhash_e2e_test.go" "balancer/ringhash/ringhash_e2e_test.go"
mkdir -p "internal/xds/balancer/cdsbalancer"
cp "/tests/internal/xds/balancer/cdsbalancer/cdsbalancer_security_test.go" "internal/xds/balancer/cdsbalancer/cdsbalancer_security_test.go"
mkdir -p "internal/xds/balancer/cdsbalancer"
cp "/tests/internal/xds/balancer/cdsbalancer/cdsbalancer_test.go" "internal/xds/balancer/cdsbalancer/cdsbalancer_test.go"
mkdir -p "internal/xds/balancer/cdsbalancer/e2e_test"
cp "/tests/internal/xds/balancer/cdsbalancer/e2e_test/balancer_test.go" "internal/xds/balancer/cdsbalancer/e2e_test/balancer_test.go"
mkdir -p "internal/xds/balancer/clusterimpl/tests"
cp "/tests/internal/xds/balancer/clusterimpl/tests/balancer_test.go" "internal/xds/balancer/clusterimpl/tests/balancer_test.go"
mkdir -p "internal/xds/httpfilter/fault"
cp "/tests/internal/xds/httpfilter/fault/fault_test.go" "internal/xds/httpfilter/fault/fault_test.go"
mkdir -p "internal/xds/resolver"
cp "/tests/internal/xds/resolver/helpers_test.go" "internal/xds/resolver/helpers_test.go"
mkdir -p "internal/xds/resolver"
cp "/tests/internal/xds/resolver/xds_http_filters_test.go" "internal/xds/resolver/xds_http_filters_test.go"
mkdir -p "internal/xds/resolver"
cp "/tests/internal/xds/resolver/xds_resolver_test.go" "internal/xds/resolver/xds_resolver_test.go"
mkdir -p "internal/xds/xdsclient/tests"
cp "/tests/internal/xds/xdsclient/tests/resource_update_test.go" "internal/xds/xdsclient/tests/resource_update_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_client_ack_nack_test.go" "test/xds/xds_client_ack_nack_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_client_certificate_providers_test.go" "test/xds/xds_client_certificate_providers_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_client_federation_test.go" "test/xds/xds_client_federation_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_client_ignore_resource_deletion_test.go" "test/xds/xds_client_ignore_resource_deletion_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_security_config_nack_test.go" "test/xds/xds_security_config_nack_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_server_integration_test.go" "test/xds/xds_server_integration_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./balancer/ringhash ./internal/xds/balancer/cdsbalancer ./internal/xds/balancer/cdsbalancer/e2e_test ./internal/xds/balancer/clusterimpl/tests ./internal/xds/httpfilter/fault ./internal/xds/resolver ./internal/xds/xdsclient/tests ./test/xds
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
