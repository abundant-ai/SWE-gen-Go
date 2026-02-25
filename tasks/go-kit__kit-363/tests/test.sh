#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "metrics/pcp"
cp "/tests/metrics/pcp/pcp_test.go" "metrics/pcp/pcp_test.go"

# Run the specific test for the PCP metrics package
go test -v ./metrics/pcp 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
