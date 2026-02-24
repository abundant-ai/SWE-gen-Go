#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tutorials/whatsup/internal"
cp "/tests/tutorials/whatsup/internal/acceptance_test.go" "tutorials/whatsup/internal/acceptance_test.go"
mkdir -p "tutorials/whatsup/internal"
cp "/tests/tutorials/whatsup/internal/playground_test.go" "tutorials/whatsup/internal/playground_test.go"

# Run tests for the specific package (tutorials/whatsup is a separate module)
cd tutorials/whatsup
go test -v ./internal 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
