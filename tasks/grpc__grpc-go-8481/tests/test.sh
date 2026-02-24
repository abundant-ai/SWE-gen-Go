#!/bin/bash

cd /app/src

# Set Go environment variables for testing
export CI=true

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "balancer/pickfirst/pickfirstleaf"
cp "/tests/balancer/pickfirst/pickfirstleaf/metrics_test.go" "balancer/pickfirst/pickfirstleaf/metrics_test.go"
mkdir -p "balancer/rls"
cp "/tests/balancer/rls/metrics_test.go" "balancer/rls/metrics_test.go"
mkdir -p "experimental/stats"
cp "/tests/experimental/stats/metricregistry_test.go" "experimental/stats/metricregistry_test.go"
mkdir -p "stats/opentelemetry/csm"
cp "/tests/stats/opentelemetry/csm/observability_test.go" "stats/opentelemetry/csm/observability_test.go"
mkdir -p "stats/opentelemetry"
cp "/tests/stats/opentelemetry/e2e_test.go" "stats/opentelemetry/e2e_test.go"

# Run the specific test packages for this PR
go test -v -timeout 7m ./balancer/pickfirst/pickfirstleaf ./balancer/rls ./experimental/stats ./stats/opentelemetry/csm ./stats/opentelemetry
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
