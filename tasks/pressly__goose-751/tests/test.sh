#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/testing/integration"
cp "/tests/internal/testing/integration/postgres_locking_test.go" "internal/testing/integration/postgres_locking_test.go"
mkdir -p "."
cp "/tests/provider_run_test.go" "provider_run_test.go"

# Run the specific test files from the PR
# Run TestHasPending from provider_run_test.go (the new test added in this PR)
go test -v . -run TestHasPending
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
