#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "tests/e2e"
cp "/tests/e2e/migrations_test.go" "tests/e2e/migrations_test.go"

# The timeout tests require Docker which isn't available in this environment.
# Instead, we verify the fix by:
# 1. Checking that the e2e test file compiles (validates the timeout tests exist)
# 2. Verifying the CLI binary has the -timeout flag (validates the fix is applied)

# First, verify the e2e test package compiles
# In buggy state: will FAIL because TestMigrateUpTimeout and TestMigrateDownTimeout don't exist
# In fixed state: will PASS because the timeout tests exist
go test -c -o /tmp/e2e.test ./tests/e2e
test_status=$?

# Additional verification: check if the CLI has the -timeout flag
if [ $test_status -eq 0 ]; then
    # Build the CLI binary
    go build -o /tmp/goose ./cmd/goose || exit 1

    # Check if -timeout flag is mentioned in help output
    if /tmp/goose -h 2>&1 | grep -q "\-timeout"; then
        # Flag exists - this is the fixed state
        test_status=0
    else
        # Flag missing - this is the buggy state (compilation passed but flag removed)
        test_status=1
    fi
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
