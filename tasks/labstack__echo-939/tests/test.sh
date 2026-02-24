#!/bin/bash

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "middleware"
cp "/tests/middleware/casbin_auth_test.go" "middleware/casbin_auth_test.go"

# Update dependencies (fetch casbin if needed after fix is applied)
dep ensure 2>/dev/null || true

# Run Go tests for the middleware package
go test -v ./middleware
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
