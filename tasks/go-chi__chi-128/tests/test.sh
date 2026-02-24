#!/bin/bash

cd /app/src/github.com/go-chi/chi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/middleware18_test.go" "middleware/middleware18_test.go"
mkdir -p "middleware"
cp "/tests/middleware/middleware_test.go" "middleware/middleware_test.go"

# Run tests for the specific files from this PR
# Test both the main package and middleware package
# Skip docgen which has import issues with old package path
go test -v . ./middleware
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
