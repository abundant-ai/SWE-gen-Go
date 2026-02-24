#!/bin/bash

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/compress_test.go" "middleware/compress_test.go"

# Copy testdata files needed by tests
mkdir -p "middleware/testdata/compress"
cp "/tests/middleware/testdata/compress/data" "middleware/testdata/compress/data"

# Run Go tests for the middleware package
go test -v ./middleware
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
