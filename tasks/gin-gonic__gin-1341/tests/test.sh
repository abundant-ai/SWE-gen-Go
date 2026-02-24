#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_body_test.go" "binding/binding_body_test.go"
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"

# Run tests from binding_body_test.go (TestBindingBody*) and context_test.go (TestContext*)
go test -v -run="^(TestBindingBody|TestContext)" ./... 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
