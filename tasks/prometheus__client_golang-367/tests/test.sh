#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/counter_test.go" "prometheus/counter_test.go"
cp "/tests/prometheus/gauge_test.go" "prometheus/gauge_test.go"
cp "/tests/prometheus/go_collector_test.go" "prometheus/go_collector_test.go"

# Run only the specific tests from the PR test files
go test -v ./prometheus -run "^(TestCounterAdd|TestCounterVecGetMetricWithInvalidLabelValues|TestCounterAddInf|TestCounterAddLarge|TestCounterAddSmall|TestGaugeConcurrency|TestGaugeVecConcurrency|TestGaugeFunc|TestGaugeSetCurrentTime|TestGoCollector|TestGCCollector)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
