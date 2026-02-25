#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/ztest"
cp "/tests/internal/ztest/clock_test.go" "internal/ztest/clock_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/buffered_write_syncer_test.go" "zapcore/buffered_write_syncer_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/clock_test.go" "zapcore/clock_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/sampler_test.go" "zapcore/sampler_test.go"

# Run tests for the modified test files
go test -v ./internal/ztest/... ./zapcore/...
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
