#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/instrument_client_1_8_test.go" "prometheus/promhttp/instrument_client_1_8_test.go"

# Run only the specific tests from the PR test file
go test -v ./prometheus/promhttp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
