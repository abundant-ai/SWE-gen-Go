#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/example_cors_method_middleware_test.go" "example_cors_method_middleware_test.go"
mkdir -p "."
cp "/tests/middleware_test.go" "middleware_test.go"

# Run tests from example_cors_method_middleware_test.go and middleware_test.go
go test -v -run "^Test" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
