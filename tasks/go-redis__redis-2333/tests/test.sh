#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
cp "/tests/cluster_test.go" "cluster_test.go"
cp "/tests/options_test.go" "options_test.go"
cp "/tests/redis_test.go" "redis_test.go"
cp "/tests/ring_test.go" "ring_test.go"
cp "/tests/sentinel_test.go" "sentinel_test.go"

# Run tests in the current package (tests from the modified files)
go test -v -run "TestParseURL|TestNewFailoverClusterClient|TestSentinelClientName"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
