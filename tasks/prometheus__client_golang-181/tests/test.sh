#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/benchmark_test.go" "prometheus/benchmark_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/vec_test.go" "prometheus/vec_test.go"

# Run tests and benchmarks from the three updated test files
# Tests from vec_test.go: TestDelete, TestDeleteLabelValues
# Tests from histogram_test.go: TestHistogramConcurrency, TestHistogramVecConcurrency, TestBuckets
# Benchmarks from benchmark_test.go and histogram_test.go (run with -benchtime=1x to make them fast)
go test -v ./prometheus -run "^(TestDelete|TestDeleteLabelValues|TestHistogramConcurrency|TestHistogramVecConcurrency|TestBuckets)$" -bench "^(BenchmarkCounterWithLabelValues|BenchmarkCounterWithLabelValuesConcurrent|BenchmarkCounterWithMappedLabels|BenchmarkCounterWithPreparedMappedLabels|BenchmarkCounterNoLabels|BenchmarkGaugeWithLabelValues|BenchmarkGaugeNoLabels|BenchmarkSummaryWithLabelValues|BenchmarkSummaryNoLabels|BenchmarkHistogramWithLabelValues|BenchmarkHistogramNoLabels|BenchmarkHistogramObserve|BenchmarkHistogramWrite)$" -benchtime=1x
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
