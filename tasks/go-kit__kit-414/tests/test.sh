#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/http"
cp "/tests/transport/http/example_test.go" "transport/http/example_test.go"
mkdir -p "transport/http"
cp "/tests/transport/http/server_test.go" "transport/http/server_test.go"

# Run tests for the specific package containing the modified test files
go test -v ./transport/http 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
