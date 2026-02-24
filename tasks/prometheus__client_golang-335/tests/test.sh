#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/counter_test.go" "prometheus/counter_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/desc_test.go" "prometheus/desc_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/value_test.go" "prometheus/value_test.go"

# Run only the specific tests from the PR test files
# Exclude TestHandler and TestRegisterWithOrGet as they are not related to the UTF-8 validation fix
go test -v ./prometheus -run "^(TestCounterAdd|TestCounterVecGetMetricWithInvalidLabelValues|TestNewDescInvalidLabelValues|TestNewConstMetricInvalidLabelValues)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
