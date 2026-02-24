#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/push"
cp "/tests/prometheus/push/push_test.go" "prometheus/push/push_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/registry_test.go" "prometheus/registry_test.go"

# Run specific tests from the PR
# TestPush is from push_test.go
# TestHandler, TestAlreadyRegistered, TestRegisterUnregisterCollector, TestHistogramVecRegisterGatherConcurrency,
# TestWriteToTextfile, TestAlreadyRegisteredCollision, TestNewMultiTRegistry, TestCheckMetricConsistency are from registry_test.go
go test -v ./prometheus/push -run "^TestPush$" 2>&1 && \
go test -v ./prometheus -run "^(TestHandler|TestAlreadyRegistered|TestRegisterUnregisterCollector|TestHistogramVecRegisterGatherConcurrency|TestWriteToTextfile|TestAlreadyRegisteredCollision|TestNewMultiTRegistry|TestCheckMetricConsistency)$" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
