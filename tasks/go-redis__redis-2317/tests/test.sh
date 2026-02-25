#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/commands_test.go" "commands_test.go"
mkdir -p "internal/hscan"
cp "/tests/internal/hscan/hscan_test.go" "internal/hscan/hscan_test.go"

# Run tests in internal/hscan package
# This tests the Scanner interface implementation which is added by the fix
go test -v ./internal/hscan
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
