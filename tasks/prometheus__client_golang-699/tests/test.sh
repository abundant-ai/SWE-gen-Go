#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "api"
cp "/tests/api/client_test.go" "api/client_test.go"
mkdir -p "api/prometheus/v1"
cp "/tests/api/prometheus/v1/api_test.go" "api/prometheus/v1/api_test.go"

# Run tests for the specific packages that were modified
go test -v ./api ./api/prometheus/v1 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
