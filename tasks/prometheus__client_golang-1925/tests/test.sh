#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus/promhttp"
cp "/tests/prometheus/promhttp/http_test.go" "prometheus/promhttp/http_test.go"

# Run only the specific test files for this PR
go test -v ./prometheus/promhttp
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
