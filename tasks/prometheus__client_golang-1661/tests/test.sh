#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "prometheus"
cp "/tests/prometheus/atomic_update_test.go" "prometheus/atomic_update_test.go"

# Run tests for the specific test file
go test -v ./prometheus -run TestAtomicUpdateFloat
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
