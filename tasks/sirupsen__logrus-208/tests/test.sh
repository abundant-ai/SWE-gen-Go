#!/bin/bash

cd /go/src/github.com/sirupsen/logrus

# Copy HEAD test files from /tests (overwrites BASE state)
mkdir -p "."
cp "/tests/entry_test.go" "entry_test.go"

# Run the entry tests
go test -v -run TestEntry .
test_status=$?

if [ $test_status -eq 0 ]; then
  echo 1 > /logs/verifier/reward.txt
else
  echo 0 > /logs/verifier/reward.txt
fi
exit "$test_status"
