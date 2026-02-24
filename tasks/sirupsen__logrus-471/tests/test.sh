#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/formatter_bench_test.go" "formatter_bench_test.go"

# Clean up any problematic tool files in dependencies (they conflict with the unix package)
find /go/src/golang.org/x/sys/unix -name "mk*.go" -delete 2>/dev/null || true

# Run the benchmark tests from the root package
go test -v -bench=. -run=^$ . 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
