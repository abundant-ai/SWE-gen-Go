#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/metric_test.go" "prometheus/metric_test.go"

# Run only the specific tests from metric_test.go
go test -v -run "^(TestBuildFQName|TestWithExemplarsMetric)$" ./prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
