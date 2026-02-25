#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/main_test.go" "main_test.go"
mkdir -p "."
cp "/tests/preload_test.go" "preload_test.go"

# Clean Go module cache, tidy, and download dependencies after updating test files
rm -f go.sum
go mod tidy
go mod download

# Run the specific tests modified in this PR with race detector
# TestTableNameConcurrently tests concurrent table name lookups (requires proper locking)
# The race detector will catch data races in the BASE state (without proper locking)
go test -race -v -run '^(TestTableNameConcurrently)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
