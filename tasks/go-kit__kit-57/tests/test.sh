#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "ratelimit"
cp "/tests/ratelimit/token_bucket_test.go" "ratelimit/token_bucket_test.go"

# Run the specific tests for the ratelimit package
go test -v ./ratelimit 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
