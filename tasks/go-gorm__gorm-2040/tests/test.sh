#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/naming_test.go" "naming_test.go"

# Move other test files away temporarily to avoid dependency issues
# (Go compiles all *_test.go files in the directory together)
mkdir -p /tmp/other_tests
mv *_test.go /tmp/other_tests/ 2>/dev/null || true
cp /tmp/other_tests/naming_test.go . || cp "/tests/naming_test.go" "naming_test.go"

# Run the specific tests in naming_test.go
go test -v -run '^(TestTheNamingStrategy|TestNamingStrategy)$' .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
