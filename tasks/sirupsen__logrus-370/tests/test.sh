#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Clean up any problematic tool files in dependencies
find /go/src/golang.org/x/sys/unix -name "mk*.go" -delete 2>/dev/null || true

# Copy HEAD files from /tests (overwrites BASE state)
cp "/tests/logger_bench_test.go" "logger_bench_test.go"

# This PR adds logger benchmarks with SetNoLock functionality
# Run the benchmarks to verify they compile and execute
go test -v -bench="BenchmarkDummyLogger" -run=^$ . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
