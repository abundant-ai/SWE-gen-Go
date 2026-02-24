#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/proxy_test.go" "middleware/proxy_test.go"
mkdir -p "middleware"
cp "/tests/middleware/rewrite_test.go" "middleware/rewrite_test.go"

# Run Go tests for middleware package tests (proxy and rewrite)
go test -v ./middleware -run "^(TestRewritePath|TestProxy|TestRewriteAfter|TestEchoRewrite)"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
