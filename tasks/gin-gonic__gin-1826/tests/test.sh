#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/routes_test.go" "routes_test.go"
mkdir -p "."
cp "/tests/tree_test.go" "tree_test.go"

# Download any new dependencies that HEAD test files need
go mod tidy && go mod download

# Run tests for the root package (routes_test.go and tree_test.go)
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
