#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/options_test.go" "options_test.go"

# Run the specific test file for this PR
# This tests the URL parsing and options configuration logic
go test -v -run "TestParseURL|TestReadTimeoutOptions|TestProtocolOptions|TestMaxConcurrentDialsOptions|TestClusterOptionsDialerRetries|TestRingOptionsDialerRetries|TestFailoverOptionsDialerRetries" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
