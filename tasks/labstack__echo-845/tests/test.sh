#!/bin/bash

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/logger_test.go" "middleware/logger_test.go"
mkdir -p "middleware"
cp "/tests/middleware/request_id_test.go" "middleware/request_id_test.go"

# Run Go tests for the middleware package
go test -v ./middleware
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
