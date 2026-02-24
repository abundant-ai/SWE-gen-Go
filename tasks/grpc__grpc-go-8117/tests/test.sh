#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "xds/internal/balancer/cdsbalancer"
cp "/tests/xds/internal/balancer/cdsbalancer/cdsbalancer_test.go" "xds/internal/balancer/cdsbalancer/cdsbalancer_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/ads_stream_ack_nack_test.go" "xds/internal/xdsclient/tests/ads_stream_ack_nack_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/authority_test.go" "xds/internal/xdsclient/tests/authority_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/cds_watchers_test.go" "xds/internal/xdsclient/tests/cds_watchers_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/eds_watchers_test.go" "xds/internal/xdsclient/tests/eds_watchers_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/lds_watchers_test.go" "xds/internal/xdsclient/tests/lds_watchers_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/misc_watchers_test.go" "xds/internal/xdsclient/tests/misc_watchers_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/rds_watchers_test.go" "xds/internal/xdsclient/tests/rds_watchers_test.go"

# Run tests on the specific packages
# Tests in xds/internal/balancer/cdsbalancer and xds/internal/xdsclient/tests
go test -v -timeout 7m ./xds/internal/balancer/cdsbalancer ./xds/internal/xdsclient/tests
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
