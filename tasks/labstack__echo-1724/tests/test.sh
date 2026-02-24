#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/rate_limiter_test.go" "middleware/rate_limiter_test.go"

# Run Go tests for rate_limiter in middleware package
go test -v ./middleware -run "RateLimiter"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
