#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "auth/basic"
cp "/tests/auth/basic/middleware_test.go" "auth/basic/middleware_test.go"

# Run the tests for this PR
go test -v ./auth/basic
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
