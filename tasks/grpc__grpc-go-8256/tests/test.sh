#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "stats/opentelemetry"
cp "/tests/stats/opentelemetry/e2e_test.go" "stats/opentelemetry/e2e_test.go"
mkdir -p "test/xds"
cp "/tests/xds/xds_telemetry_labels_test.go" "test/xds/xds_telemetry_labels_test.go"
mkdir -p "xds/internal/balancer/clusterimpl"
cp "/tests/xds/internal/balancer/clusterimpl/balancer_test.go" "xds/internal/balancer/clusterimpl/balancer_test.go"
mkdir -p "xds/internal/balancer/clusterresolver"
cp "/tests/xds/internal/balancer/clusterresolver/configbuilder_test.go" "xds/internal/balancer/clusterresolver/configbuilder_test.go"
mkdir -p "xds/internal/balancer/wrrlocality"
cp "/tests/xds/internal/balancer/wrrlocality/balancer_test.go" "xds/internal/balancer/wrrlocality/balancer_test.go"
mkdir -p "xds/internal"
cp "/tests/xds/internal/internal_test.go" "xds/internal/internal_test.go"
mkdir -p "xds/internal/xdsclient/tests"
cp "/tests/xds/internal/xdsclient/tests/loadreport_test.go" "xds/internal/xdsclient/tests/loadreport_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./stats/opentelemetry/... ./test/xds/... ./xds/internal/balancer/clusterimpl/... ./xds/internal/balancer/clusterresolver/... ./xds/internal/balancer/wrrlocality/... ./xds/internal/... ./xds/internal/xdsclient/tests/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
