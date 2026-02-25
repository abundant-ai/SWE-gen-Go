#!/bin/bash

cd /go/src/github.com/peterbourgon/gokit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "transport/codec/json"
cp "/tests/transport/codec/json/json_test.go" "transport/codec/json/json_test.go"
mkdir -p "transport/http"
cp "/tests/transport/http/binding_test.go" "transport/http/binding_test.go"

# Run the specific tests for transport/codec/json and transport/http packages
go test -v ./transport/codec/json ./transport/http 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
