#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/example_test.go" "exp/zapslog/example_test.go"
mkdir -p "exp/zapslog"
cp "/tests/exp/zapslog/handler_test.go" "exp/zapslog/handler_test.go"

# Run tests for the zapslog package in the exp module
cd exp && go test -v ./zapslog
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
