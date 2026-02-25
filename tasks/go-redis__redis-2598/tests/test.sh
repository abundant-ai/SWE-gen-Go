#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/cluster_test.go" "cluster_test.go"
mkdir -p "."
cp "/tests/options_test.go" "options_test.go"
mkdir -p "."
cp "/tests/redis_test.go" "redis_test.go"
mkdir -p "."
cp "/tests/ring_test.go" "ring_test.go"
mkdir -p "."
cp "/tests/sentinel_test.go" "sentinel_test.go"

# Run only the tests from the specific test files for this PR
# Use -run flag to match only the test functions from those files
go test -v -run "^(TestParseURL|TestReadTimeoutOptions|TestHookError)$"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
