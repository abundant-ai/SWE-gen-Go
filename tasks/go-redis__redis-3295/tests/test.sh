#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/bench_decode_test.go" "bench_decode_test.go"
mkdir -p "."
cp "/tests/redis_test.go" "redis_test.go"

# Run the specific test files from this PR
# Tests should FAIL in BASE state (reward=0) and PASS after fix (reward=1)
go test -v . -run TestBenchDecode
go test -v . -run TestRedis
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
