#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/migrationstats"
cp "/tests/internal/migrationstats/migrationstats_test.go" "internal/migrationstats/migrationstats_test.go"

# Run the specific test files from the PR
go test -v ./internal/migrationstats
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
