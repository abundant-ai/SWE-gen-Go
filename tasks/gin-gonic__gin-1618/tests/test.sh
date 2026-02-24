#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "binding"
cp "/tests/binding/binding_body_test.go" "binding/binding_body_test.go"
mkdir -p "binding"
cp "/tests/binding/binding_test.go" "binding/binding_test.go"
mkdir -p "."
cp "/tests/context_test.go" "context_test.go"

# Download any new dependencies that HEAD test files need
go mod tidy && go mod download

# Run tests for binding package and context_test.go in root package
# Use -mod=mod to ignore vendor directory inconsistencies
go test -v -mod=mod ./binding .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
