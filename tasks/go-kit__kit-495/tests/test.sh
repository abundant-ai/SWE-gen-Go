#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/cloudwatch"
cp "/tests/metrics/cloudwatch/cloudwatch_test.go" "metrics/cloudwatch/cloudwatch_test.go"

# Run tests for the cloudwatch package
go test -v ./metrics/cloudwatch 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
