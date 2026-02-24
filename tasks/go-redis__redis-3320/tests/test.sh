#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "auth"
cp "/tests/auth/auth_test.go" "auth/auth_test.go"
mkdir -p "."
cp "/tests/command_recorder_test.go" "command_recorder_test.go"
mkdir -p "doctests"
cp "/tests/doctests/lpush_lrange_test.go" "doctests/lpush_lrange_test.go"
mkdir -p "."
cp "/tests/example_instrumentation_test.go" "example_instrumentation_test.go"
mkdir -p "."
cp "/tests/internal_test.go" "internal_test.go"
mkdir -p "."
cp "/tests/osscluster_test.go" "osscluster_test.go"
mkdir -p "."
cp "/tests/probabilistic_test.go" "probabilistic_test.go"
mkdir -p "."
cp "/tests/redis_test.go" "redis_test.go"
mkdir -p "."
cp "/tests/ring_test.go" "ring_test.go"

# Run the specific test files from this PR
# Tests should FAIL in BASE state (reward=0) and PASS after fix (reward=1)
go test -v ./auth -run TestAuth
go test -v . -run TestCommandRecorder
go test -v ./doctests -run TestLPushLRange
go test -v . -run TestExampleInstrumentation
go test -v . -run TestInternal
go test -v . -run TestOSSCluster
go test -v . -run TestProbabilistic
go test -v . -run TestRedis
go test -v . -run TestRing
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
