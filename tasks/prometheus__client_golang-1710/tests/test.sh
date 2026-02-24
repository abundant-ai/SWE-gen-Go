#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "api/prometheus/v1/remote"
cp "/tests/api/prometheus/v1/remote/remote_api_test.go" "api/prometheus/v1/remote/remote_api_test.go"

# Run tests for the specific package
go test -v ./api/prometheus/v1/remote
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
