#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/histogram_test.go" "prometheus/histogram_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/http_test.go" "prometheus/promhttp/http_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/instrument_server_test.go" "prometheus/promhttp/instrument_server_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/summary_test.go" "prometheus/summary_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/timer_test.go" "prometheus/timer_test.go"

# Run only the specific tests from the PR test files
go test -v -run "^(TestHistogramNonMonotonicBuckets|TestHistogramConcurrency|TestHistogramVecConcurrency|TestBuckets|TestSummaryWithDefaultObjectives|TestSummaryWithoutObjectives|TestSummaryConcurrency|TestSummaryVecConcurrency|TestSummaryDecay|TestTimerObserve|TestTimerEmpty|TestTimerConditionalTiming|TestTimerByOutcome)$" ./prometheus && \
go test -v -run "^(TestHandlerErrorHandling|TestMiddlewareAPI)$" ./prometheus/promhttp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
