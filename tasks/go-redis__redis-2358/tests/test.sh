#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/redis_test.go" "redis_test.go"

# Run only the Hook test using Ginkgo's focus flag
# This avoids running the entire test suite which has unrelated failures
go test -v -a -run TestGinkgoSuite -ginkgo.focus="Hook"
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
