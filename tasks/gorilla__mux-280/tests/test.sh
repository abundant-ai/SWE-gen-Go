#!/bin/bash

export GOPATH="/go"
cd "${GOPATH}/src/github.com/gorilla/mux"

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/mux_test.go" "mux_test.go"

# Run tests from mux_test.go
go test -v -run "^Test" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
