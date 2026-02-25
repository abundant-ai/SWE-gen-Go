#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "benchmarks"
cp "/tests/benchmarks/scenario_bench_test.go" "benchmarks/scenario_bench_test.go"
mkdir -p "benchmarks"
cp "/tests/benchmarks/slog_test.go" "benchmarks/slog_test.go"

# Run tests in the benchmarks package
cd benchmarks && go test -v .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
