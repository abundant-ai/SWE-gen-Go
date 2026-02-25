#!/bin/bash

cd /go/src/github.com/peterbourgon/gokit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/expvar"
cp "/tests/metrics/expvar/expvar_test.go" "metrics/expvar/expvar_test.go"
mkdir -p "metrics"
cp "/tests/metrics/multi_test.go" "metrics/multi_test.go"
mkdir -p "metrics/prometheus"
cp "/tests/metrics/prometheus/prometheus_test.go" "metrics/prometheus/prometheus_test.go"
mkdir -p "metrics"
cp "/tests/metrics/scaled_histogram_test.go" "metrics/scaled_histogram_test.go"
mkdir -p "metrics/statsd"
cp "/tests/metrics/statsd/statsd_test.go" "metrics/statsd/statsd_test.go"
mkdir -p "metrics"
cp "/tests/metrics/time_histogram_test.go" "metrics/time_histogram_test.go"

# Run the specific tests for metrics subpackages that don't depend on wrapper functions
# Note: multi_test.go, scaled_histogram_test.go, and time_histogram_test.go require
# wrapper functions (metrics.NewExpvarCounter, etc.) that aren't part of this PR's scope
go test -v ./metrics/expvar ./metrics/statsd ./metrics/prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
