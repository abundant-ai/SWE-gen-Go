#!/bin/bash

cd /go/src/github.com/labstack/echo

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/echo_test.go" "echo_test.go"

# Run Go tests for the root package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
