#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/graphite"
cp "/tests/metrics/graphite/graphite_test.go" "metrics/graphite/graphite_test.go"
mkdir -p "metrics/graphite"
cp "/tests/metrics/graphite/manager_test.go" "metrics/graphite/manager_test.go"

# Run the specific tests for the metrics/graphite package
go test -v ./metrics/graphite 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
