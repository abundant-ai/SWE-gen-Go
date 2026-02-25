#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/proto"
cp "/tests/internal/proto/writer_test.go" "internal/proto/writer_test.go"

# Run the specific test file for this PR
go test -v ./internal/proto
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
