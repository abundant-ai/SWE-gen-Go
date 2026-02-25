#!/bin/bash

cd /go/src/github.com/go-kit/kit

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "log/deprecated_levels"
cp "/tests/log/deprecated_levels/levels_test.go" "log/deprecated_levels/levels_test.go"
mkdir -p "log/level"
cp "/tests/log/level/benchmark_test.go" "log/level/benchmark_test.go"
mkdir -p "log/level"
cp "/tests/log/level/example_test.go" "log/level/example_test.go"
mkdir -p "log/level"
cp "/tests/log/level/level_test.go" "log/level/level_test.go"

# Run tests for the specific packages touched by this PR
go test -v ./log/deprecated_levels ./log/level 2>&1
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
