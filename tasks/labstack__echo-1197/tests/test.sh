#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/proxy_1_11_test.go" "middleware/proxy_1_11_test.go"
mkdir -p "middleware"
cp "/tests/middleware/proxy_test.go" "middleware/proxy_test.go"

# Run Go tests for the middleware package
go test -v ./middleware
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
