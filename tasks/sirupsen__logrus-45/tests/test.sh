#!/bin/bash

cd /app/src

# Set environment variables for Go tests
export CGO_ENABLED=0

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/hook_test.go" "hook_test.go"

# Run only the specific test file for this PR
# Disable vet to allow compilation (code may have fmt.Fprintf with missing format directives)
go test -vet=off -v -run TestAllHooks .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
