#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/main_test.go" "main_test.go"
mkdir -p "."
cp "/tests/monitor_test.go" "monitor_test.go"

# Start Redis server on port 6379 for monitor tests
mkdir -p /tmp/redis-6379
testdata/redis/src/redis-server --port 6379 --dir /tmp/redis-6379 --daemonize yes --save ""

# Wait for Redis to be ready
sleep 1

# Run only the Monitor tests (the tests affected by this PR)
go test -v -run=TestGinkgoSuite -ginkgo.focus="Monitor command" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
