#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "internal/lang/marks"
cp "/tests/internal/lang/marks/marks_test.go" "internal/lang/marks/marks_test.go"
mkdir -p "internal/lang/marks"
cp "/tests/internal/lang/marks/paths_test.go" "internal/lang/marks/paths_test.go"

# Run tests for the specific package
go test -v ./internal/lang/marks
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
