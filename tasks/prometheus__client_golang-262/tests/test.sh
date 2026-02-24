#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/benchmark_test.go" "prometheus/benchmark_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/http_test.go" "prometheus/http_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/summary_test.go" "prometheus/summary_test.go"

# Run only the specific tests from the PR test files
go test -v -run "^(TestInstrumentHandler|TestSummaryConcurrency|TestSummaryDecay|TestSummaryVecConcurrency|TestSummaryWithDefaultObjectives|TestSummaryWithoutObjectives)$" ./prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
