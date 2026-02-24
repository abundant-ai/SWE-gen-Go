#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"
mkdir -p "middleware"
cp "/tests/middleware/middleware_test.go" "middleware/middleware_test.go"
mkdir -p "middleware"
cp "/tests/middleware/proxy_test.go" "middleware/proxy_test.go"
mkdir -p "middleware"
cp "/tests/middleware/rewrite_test.go" "middleware/rewrite_test.go"

# Run Go tests for echo_test.go at root level
go test -v . -run "^TestEcho"
test_status_root=$?

# Run Go tests for middleware package tests
go test -v ./middleware -run "^(TestRewritePath|TestProxy|TestRewriteAfter|TestEchoRewrite)"
test_status_middleware=$?

# Overall test status: both must pass
if [ $test_status_root -eq 0 ] && [ $test_status_middleware -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
