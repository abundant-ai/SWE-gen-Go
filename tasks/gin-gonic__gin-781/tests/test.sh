#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/context_test.go" "context_test.go"
cp "/tests/middleware_test.go" "middleware_test.go"

# Run tests - testing context_test.go and middleware_test.go
go test -v -run "TestContext|TestMiddleware" . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
