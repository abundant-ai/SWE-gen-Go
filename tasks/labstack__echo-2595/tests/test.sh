#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/body_dump_test.go" "middleware/body_dump_test.go"
mkdir -p "middleware"
cp "/tests/middleware/compress_test.go" "middleware/compress_test.go"
mkdir -p "middleware"
cp "/tests/middleware/middleware_test.go" "middleware/middleware_test.go"
mkdir -p "."
cp "/tests/response_test.go" "response_test.go"

# Run Go tests for the specific test files from this PR
go test -v ./middleware -run "TestBodyDump|TestCompress|TestMiddleware" && \
go test -v . -run "TestResponse"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
