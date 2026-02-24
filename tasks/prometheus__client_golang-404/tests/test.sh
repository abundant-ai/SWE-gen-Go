#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "api"
cp "/tests/api/client_test.go" "api/client_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/expvar_collector_test.go" "prometheus/expvar_collector_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/http_test.go" "prometheus/http_test.go"
mkdir -p "prometheus"
cp "/tests/prometheus/process_collector_test.go" "prometheus/process_collector_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/http_test.go" "prometheus/promhttp/http_test.go"

# Run tests for the packages containing the test files
go test -v ./api ./prometheus ./prometheus/promhttp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
