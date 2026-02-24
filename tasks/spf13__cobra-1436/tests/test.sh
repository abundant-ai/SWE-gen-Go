#!/bin/bash

cd /app/src

export GO111MODULE=on

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "cobra/cmd"
cp "/tests/cobra/cmd/add_test.go" "cobra/cmd/add_test.go"
mkdir -p "cobra/cmd"
cp "/tests/cobra/cmd/init_test.go" "cobra/cmd/init_test.go"

# Run tests from the specific test files modified in this PR
# cobra/cmd/add_test.go and cobra/cmd/init_test.go - run tests in the cobra/cmd package
go test -v ./cobra/cmd
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
