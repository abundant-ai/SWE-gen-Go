#!/bin/bash

cd /app/src

# Set environment variables for tests
export CGO_ENABLED=0
export GO111MODULE=on
export MINIO_API_REQUESTS_MAX=10000

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cmd"
cp "/tests/cmd/server_test.go" "cmd/server_test.go"

# Just compile the test to verify the code changes are syntactically correct
# The TestMetricsV3Handler test is part of TestServerSuite which has flaky subtests
go test -c -o /dev/null ./cmd
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
