#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/example_selfcollector_test.go" "prometheus/example_selfcollector_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/examples_test.go" "prometheus/examples_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_test.go" "prometheus/go_collector_test.go"

# Run tests for the prometheus package, excluding TestProcessCollector which has environmental issues
go test -v github.com/prometheus/client_golang/prometheus -run="^(Test(Counter|Gauge|Go|Instrument|Build|Handler|Summary|Delete)|Example)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
