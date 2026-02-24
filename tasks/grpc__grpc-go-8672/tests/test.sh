#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/endpointsharding"
cp "/tests/balancer/endpointsharding/endpointsharding_ext_test.go" "balancer/endpointsharding/endpointsharding_ext_test.go"
mkdir -p "balancer/lazy"
cp "/tests/balancer/lazy/lazy_ext_test.go" "balancer/lazy/lazy_ext_test.go"
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/metrics_test.go" "balancer/pickfirst/metrics_test.go"
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/pickfirst_ext_test.go" "balancer/pickfirst/pickfirst_ext_test.go"
mkdir -p "balancer/pickfirst"
cp "/tests/balancer/pickfirst/pickfirst_test.go" "balancer/pickfirst/pickfirst_test.go"
mkdir -p "."
cp "/tests/clientconn_test.go" "clientconn_test.go"
mkdir -p "internal/xds/balancer/outlierdetection"
cp "/tests/internal/xds/balancer/outlierdetection/balancer_test.go" "internal/xds/balancer/outlierdetection/balancer_test.go"
mkdir -p "internal/xds/balancer/outlierdetection/e2e_test"
cp "/tests/internal/xds/balancer/outlierdetection/e2e_test/outlierdetection_test.go" "internal/xds/balancer/outlierdetection/e2e_test/outlierdetection_test.go"
mkdir -p "test"
cp "/tests/clientconn_state_transition_test.go" "test/clientconn_state_transition_test.go"
mkdir -p "xds/googledirectpath"
cp "/tests/xds/googledirectpath/googlec2p_test.go" "xds/googledirectpath/googlec2p_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m . ./balancer/endpointsharding ./balancer/lazy ./balancer/pickfirst ./internal/xds/balancer/outlierdetection ./internal/xds/balancer/outlierdetection/e2e_test ./test ./xds/googledirectpath
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
