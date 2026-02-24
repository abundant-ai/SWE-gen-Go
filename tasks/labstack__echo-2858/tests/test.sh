#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/csrf_test.go" "middleware/csrf_test.go"
cp "/tests/middleware/util_test.go" "middleware/util_test.go"

# Run Go tests for the middleware package
go test -v ./middleware/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
