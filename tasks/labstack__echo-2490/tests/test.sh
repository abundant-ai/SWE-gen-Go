#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/csrf_test.go" "middleware/csrf_test.go"
mkdir -p "middleware"
cp "/tests/middleware/rate_limiter_test.go" "middleware/rate_limiter_test.go"
mkdir -p "middleware"
cp "/tests/middleware/util_test.go" "middleware/util_test.go"

# Run Go tests for the specific test files from this PR
go test -v ./middleware -run "TestCSRF|TestRateLimiter|TestParseAcceptEncoding"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
