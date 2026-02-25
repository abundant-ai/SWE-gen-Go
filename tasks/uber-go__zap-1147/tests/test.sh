#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "zapcore"
cp "/tests/zapcore/core_test.go" "zapcore/core_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/hook_test.go" "zapcore/hook_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/increase_level_test.go" "zapcore/increase_level_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/level_test.go" "zapcore/level_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/sampler_test.go" "zapcore/sampler_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/tee_test.go" "zapcore/tee_test.go"
mkdir -p "zaptest/observer"
cp "/tests/zaptest/observer/observer_test.go" "zaptest/observer/observer_test.go"

# Run tests in zapcore package
go test -v ./zapcore

# Run tests in zaptest/observer package
go test -v ./zaptest/observer
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
