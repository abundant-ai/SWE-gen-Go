#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/benchmark_test.go" "prometheus/benchmark_test.go"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "text"
cp "/tests/text/create_test.go" "text/create_test.go"

# Run prometheus package tests from the specific test files
# Tests: TestHistogramConcurrency, TestHistogramVecConcurrency, TestBuckets, and Example* tests
go test -v -run "^(TestHistogram|TestBuckets|Example)" github.com/prometheus/client_golang/prometheus
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
