#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/clock_test.go" "clock_test.go"
mkdir -p "."
cp "/tests/leak_test.go" "leak_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/clock_test.go" "zapcore/clock_test.go"
mkdir -p "zapcore"
cp "/tests/zapcore/leak_test.go" "zapcore/leak_test.go"
mkdir -p "zapgrpc/internal/test"
cp "/tests/zapgrpc/internal/test/go.sum" "zapgrpc/internal/test/go.sum"

# Run tests for the modified test files
# Testing clock_test.go and leak_test.go in root package
go test -v . -run "TestClock|TestLeak"
test_status_root=$?

# Testing zapcore/clock_test.go and zapcore/leak_test.go
go test -v ./zapcore -run "TestClock|TestLeak"
test_status_zapcore=$?

# Both test runs must pass
if [ $test_status_root -eq 0 ] && [ $test_status_zapcore -eq 0 ]; then
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
