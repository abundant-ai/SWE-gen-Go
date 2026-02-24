#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/counter_test.go" "prometheus/counter_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/example_metricvec_test.go" "prometheus/example_metricvec_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/expvar_collector_test.go" "prometheus/expvar_collector_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/summary_test.go" "prometheus/summary_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/utils_test.go" "prometheus/utils_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/value_test.go" "prometheus/value_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/wrap_test.go" "prometheus/wrap_test.go"

# Run the specific test files for this PR
go test -v ./prometheus -run "TestCounter|TestMetricVec|TestExpvar|TestHistogram|TestRegistry|TestSummary|TestUtils|TestValue|TestWrap" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
