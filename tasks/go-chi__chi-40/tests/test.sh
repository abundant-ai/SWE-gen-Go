#!/bin/bash

cd /app/src/github.com/go-chi/chi

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/mux_test.go" "mux_test.go"
mkdir -p "."
cp "/tests/tree_test.go" "tree_test.go"

# Run tests for the specific files from this PR
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
