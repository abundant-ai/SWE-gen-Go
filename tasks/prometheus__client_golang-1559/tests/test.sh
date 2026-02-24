#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go117_test.go" "prometheus/collectors/go_collector_go117_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go119_test.go" "prometheus/collectors/go_collector_go119_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go120_test.go" "prometheus/collectors/go_collector_go120_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go121_test.go" "prometheus/collectors/go_collector_go121_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_go122_test.go" "prometheus/collectors/go_collector_go122_test.go"
mkdir -p "prometheus/collectors"
cp "/tests/prometheus/collectors/go_collector_latest_test.go" "prometheus/collectors/go_collector_latest_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_latest_test.go" "prometheus/go_collector_latest_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_metrics_go120_test.go" "prometheus/go_collector_metrics_go120_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_metrics_go121_test.go" "prometheus/go_collector_metrics_go121_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/go_collector_metrics_go122_test.go" "prometheus/go_collector_metrics_go122_test.go"

# Run tests for the specific packages containing the test files
go test -v ./prometheus/collectors ./prometheus 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
