#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/middleware_test.go" "middleware/middleware_test.go"
mkdir -p "middleware"
cp "/tests/middleware/proxy_test.go" "middleware/proxy_test.go"
mkdir -p "middleware"
cp "/tests/middleware/rewrite_test.go" "middleware/rewrite_test.go"

# Run Go tests for the specific test files from this PR
# Testing middleware package for middleware_test.go, proxy_test.go, and rewrite_test.go
go test -v ./middleware -run "^(TestMiddleware|TestProxy|TestRewrite)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
