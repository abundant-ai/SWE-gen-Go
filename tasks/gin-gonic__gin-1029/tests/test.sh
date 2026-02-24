#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"

# Run tests from binding/binding_test.go and context_test.go
go test -v ./binding 2>&1
binding_status=$?

go test -v . 2>&1
context_status=$?

# Both test runs must pass
if [ $binding_status -eq 0 ] && [ $context_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
