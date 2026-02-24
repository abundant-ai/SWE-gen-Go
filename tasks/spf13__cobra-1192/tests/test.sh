#!/bin/bash

cd /app/src

export GO111MODULE=on

# Remove buggy state files that conflict with HEAD files
# In the buggy state, completions.go was renamed to custom_completions.go
# and completions_test.go was renamed to custom_completions_test.go
# These need to be removed so they don't conflict with the fix
rm -f custom_completions.go custom_completions_test.go

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/completions_test.go" "completions_test.go"

# Run tests from the specific test file modified in this PR
# completions_test.go - run tests in the root package
go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
