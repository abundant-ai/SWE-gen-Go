#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/errors_test.go" "errors_test.go"

# Run tests from the errors_test.go file
# Run only tests matching TestError pattern (TestError and TestErrorSlice)
go test -v -run="^TestError" 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
