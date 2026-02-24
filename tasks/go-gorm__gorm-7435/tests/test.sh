#!/bin/bash

cd /app/gorm

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests"
cp "/tests/go.mod" "tests/go.mod"
cp "/tests/lru_test.go" "tests/lru_test.go"
cp "/tests/prepared_stmt_test.go" "tests/prepared_stmt_test.go"

# Refresh test module dependencies after copying go.mod
cd tests
go mod tidy
go mod download

# Run all tests in the tests package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
