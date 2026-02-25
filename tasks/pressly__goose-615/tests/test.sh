#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/create_test.go" "create_test.go"
mkdir -p "."
cp "/tests/fix_test.go" "fix_test.go"
mkdir -p "internal/migrationstats"
cp "/tests/internal/migrationstats/migrationstats_test.go" "internal/migrationstats/migrationstats_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/collect_test.go" "internal/provider/collect_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/provider_options_test.go" "internal/provider/provider_options_test.go"
mkdir -p "internal/provider"
cp "/tests/internal/provider/provider_test.go" "internal/provider/provider_test.go"
mkdir -p "lock"
cp "/tests/lock/postgres_test.go" "lock/postgres_test.go"

# Run tests for the specific packages touched by this PR
# Use -short flag to skip tests that require Docker
go test -v -short . ./internal/migrationstats ./internal/provider ./lock
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
