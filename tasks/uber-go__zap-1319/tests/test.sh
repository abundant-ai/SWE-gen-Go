#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/logger_bench_test.go" "logger_bench_test.go"
mkdir -p "."
cp "/tests/logger_test.go" "logger_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/lazy_with_test.go" "zapcore/lazy_with_test.go"

# Run tests in the main package for logger-related tests
go test -v -run TestLogger -bench=BenchmarkLogger
main_test_status=$?

# Run tests in the zapcore package for lazy_with tests
go test -v ./zapcore -run TestLazy
zapcore_test_status=$?

# Check if both tests passed
if [ $main_test_status -eq 0 ] && [ $zapcore_test_status -eq 0 ]; then
  test_status=0
else
  test_status=1
fi

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
