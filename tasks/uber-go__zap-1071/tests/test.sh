#!/bin/bash

cd /app/src

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/array_go118_test.go" "array_go118_test.go"
mkdir -p "."
cp "/tests/example_go118_test.go" "example_go118_test.go"
mkdir -p "."
cp "/tests/example_test.go" "example_test.go"

# Run tests from the three modified test files
# All test files are in the root directory, so we test the root package
go test -v -run "^(TestArray|TestExample)" .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
