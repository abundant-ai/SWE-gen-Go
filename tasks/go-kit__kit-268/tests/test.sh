#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/dogstatsd"
cp "/tests/metrics/dogstatsd/dogstatsd_test.go" "metrics/dogstatsd/dogstatsd_test.go"
mkdir -p "metrics/graphite"
cp "/tests/metrics/graphite/graphite_test.go" "metrics/graphite/graphite_test.go"
mkdir -p "metrics/provider"
cp "/tests/metrics/provider/providers_test.go" "metrics/provider/providers_test.go"
mkdir -p "metrics/statsd"
cp "/tests/metrics/statsd/statsd_test.go" "metrics/statsd/statsd_test.go"
mkdir -p "util/conn"
cp "/tests/util/conn/manager_test.go" "util/conn/manager_test.go"

# Run the specific tests for the metrics and util packages
go test -v ./metrics/dogstatsd ./metrics/graphite ./metrics/provider ./metrics/statsd ./util/conn 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
