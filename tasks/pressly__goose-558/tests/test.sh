#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/sqlparser"
cp "/tests/internal/sqlparser/parser_test.go" "internal/sqlparser/parser_test.go"

# Run tests for the specific package touched by this PR
go test -v ./internal/sqlparser/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
