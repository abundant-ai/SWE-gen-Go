#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/main_test.go" "main_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
rm -f go.sum
go mod tidy
go mod download

# Run the specific test modified in this PR
# TestTransactionReadonly tests the new BeginTx method with read-only transactions
go test -v -run '^(TestTransactionReadonly)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
