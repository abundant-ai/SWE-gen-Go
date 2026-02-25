#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/awslambda"
cp "/tests/transport/awslambda/handler_test.go" "transport/awslambda/handler_test.go"

# Run the specific test files for this PR
go test -v ./transport/awslambda
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
