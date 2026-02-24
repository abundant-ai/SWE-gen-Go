#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/unit_test.go" "unit_test.go"
mkdir -p "."
cp "/tests/vectorset_commands_integration_test.go" "vectorset_commands_integration_test.go"
mkdir -p "."
cp "/tests/vectorset_commands_test.go" "vectorset_commands_test.go"

# Run tests in the current directory, excluding integration tests that require Redis
# The -skip flag excludes tests matching the pattern (Ginkgo suite and Example tests)
go test -v -skip "TestGinkgoSuite|Example" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
