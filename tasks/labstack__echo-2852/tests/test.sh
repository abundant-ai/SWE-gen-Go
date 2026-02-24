#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/body_dump_test.go" "middleware/body_dump_test.go"
mkdir -p "middleware"
cp "/tests/middleware/compress_test.go" "middleware/compress_test.go"
mkdir -p "middleware"
cp "/tests/middleware/logger_strings_test.go" "middleware/logger_strings_test.go"
mkdir -p "middleware"
cp "/tests/middleware/logger_test.go" "middleware/logger_test.go"
mkdir -p "middleware"
cp "/tests/middleware/rate_limiter_test.go" "middleware/rate_limiter_test.go"
mkdir -p "middleware"
cp "/tests/middleware/static_test.go" "middleware/static_test.go"
mkdir -p "middleware"
cp "/tests/middleware/timeout_test.go" "middleware/timeout_test.go"

# Run Go tests for the middleware package
go test -v ./middleware/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
