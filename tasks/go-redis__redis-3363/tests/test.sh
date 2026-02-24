#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/nil_panic_test.go" "nil_panic_test.go"

# Run tests that verify nil panic behavior for all client constructors
go test -v -run "TestClientNilOptions|TestClusterClientNilOptions|TestRingNilOptions|TestUniversalClientNilOptions|TestFailoverClientNilOptions|TestFailoverClusterClientNilOptions|TestSentinelClientNilOptions" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
