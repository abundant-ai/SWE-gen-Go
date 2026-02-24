#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/instrument_server_test.go" "prometheus/promhttp/instrument_server_test.go"
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/option_test.go" "prometheus/promhttp/option_test.go"

# Run the specific tests from the PR test files
go test -v ./prometheus/promhttp 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
