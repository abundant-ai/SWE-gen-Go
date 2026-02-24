#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"

# Run only the specific tests from the PR test files
go test -v -run '^(TestHistogramNonMonotonicBuckets|TestHistogramConcurrency|TestHistogramVecConcurrency|TestBuckets|TestHistogramAtomicObserve|TestHistogramExemplar|TestSparseHistogram)$' ./prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
