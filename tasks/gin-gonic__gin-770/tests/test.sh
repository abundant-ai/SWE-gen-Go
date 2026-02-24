#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/logger_test.go" "logger_test.go"

# Run tests - testing logger_test.go
go test -v -run "TestLogger" . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
