#!/bin/bash

cd /go/src/github.com/gin-gonic/gin

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/validate_test.go" "binding/validate_test.go"

# Run tests from binding/validate_test.go (TestValidate*)
go test -v -run="^TestValidate" ./binding 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
