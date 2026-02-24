#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/universal_test.go" "universal_test.go"

# For this task, we verify the code compiles correctly with the new tests
# The tests require Redis cluster infrastructure which isn't available in the test environment
# The fix ensures UnstableResp3 is properly propagated to cluster options, which is a compile-time check
go test -c -o /dev/null .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
